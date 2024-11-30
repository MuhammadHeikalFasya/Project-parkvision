import cv2
import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta
from ultralytics import YOLO
from flask import Flask, Response, jsonify, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

model = YOLO('yolov8s.pt')

cap = cv2.VideoCapture('Dataset parkir v2.mp4')

empty_slots = 0
occupied_slots = 0
violation_slots = 0

with open("coco.txt", "r") as my_file:
    class_list = my_file.read().split("\n")

areas = {
    "area1": [(210, 173), (19, 340), (149, 319), (315, 169)],
    "area2": [(330, 168), (172, 310), (313, 284), (450, 150)],
    "area3": [(467, 151), (333, 285), (473, 265), (578, 142)],
    "area4": [(595, 138), (492, 263), (624, 247), (693, 136)],
    "area5": [(706, 134), (640, 246), (752, 230), (787, 136)],
    "area6": [(798, 138), (766, 230), (856, 219), (871, 136)],
    "area7": [(881, 132), (868, 218), (938, 212), (953, 136)],
}

previous_detections = {}
violation_timers = {}

capture_directory = os.path.join("images", "captures")
os.makedirs(capture_directory, exist_ok=True)

def get_line_positions(area_coords, line_spacing=0.35):
    coords = np.array(area_coords, np.float32)
    width_top = coords[3][0] - coords[0][0]
    width_bottom = coords[2][0] - coords[1][0]
    positions = [line_spacing, 1 - line_spacing]
    lines = []
    
    for ratio in positions:
        top_x = coords[0][0] + ratio * width_top
        bottom_x = coords[1][0] + ratio * width_bottom
        lines.append((top_x, bottom_x))
    
    return lines

def is_between_lines(point, area_coords, line_positions):
    cx, cy = point
    coords = np.array(area_coords, np.float32)
    top_y = (coords[0][1] + coords[3][1]) / 2
    bottom_y = (coords[1][1] + coords[2][1]) / 2
    ratio = (cy - top_y) / (bottom_y - top_y)
    left_line_x = line_positions[0][0] + ratio * (line_positions[0][1] - line_positions[0][0])
    right_line_x = line_positions[1][0] + ratio * (line_positions[1][1] - line_positions[1][0])
    return left_line_x <= cx <= right_line_x

def draw_vertical_lines(frame, area_coords, line_spacing=0.35):
    coords = np.array(area_coords, np.float32)
    top_y = (coords[0][1] + coords[3][1]) / 2
    bottom_y = (coords[1][1] + coords[2][1]) / 2
    width_top = coords[3][0] - coords[0][0]
    width_bottom = coords[2][0] - coords[1][0]
    positions = [line_spacing, 1 - line_spacing]
    
    for ratio in positions:
        top_x = coords[0][0] + ratio * width_top
        bottom_x = coords[1][0] + ratio * width_bottom
        start_point = (int(top_x), int(top_y))
        end_point = (int(bottom_x), int(bottom_y))
        cv2.line(frame, start_point, end_point, (0, 255, 255), 2)

def generate_frames():
    global empty_slots, occupied_slots, violation_slots
    global previous_detections, violation_timers
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.resize(frame, (1020, 500))
        results = model.predict(frame, verbose=False)
        detections = pd.DataFrame(results[0].boxes.data).astype("float")
        area_counts = {area_name: 0 for area_name in areas}
        violations = {area_name: 0 for area_name in areas}
        current_detections = {}

        for index, row in detections.iterrows():
            x1, y1, x2, y2 = int(row[0]), int(row[1]), int(row[2]), int(row[3])
            class_id = int(row[5])
            class_name = class_list[class_id]

            if class_name in ["suitcase", "person", "car"]:
                cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
                is_inside_area = False
                is_violation = True

                for area_name, area_coords in areas.items():
                    if cv2.pointPolygonTest(np.array(area_coords, np.int32), (cx, cy), False) >= 0:
                        area_counts[area_name] += 1
                        is_inside_area = True

                        line_positions = get_line_positions(area_coords, line_spacing=0.35)
                        if is_between_lines((cx, cy), area_coords, line_positions):
                            is_violation = False

                        current_detections[index] = (x1, y1, x2, y2, is_violation, cx, cy)
                        if is_violation:
                            violations[area_name] += 1
                        break

                if not is_inside_area:
                    current_detections[index] = (x1, y1, x2, y2, True, cx, cy)

        for index, (x1, y1, x2, y2, is_violation, cx, cy) in current_detections.items():
            if index in previous_detections:
                prev_x1, prev_y1, prev_x2, prev_y2, prev_is_violation, prev_cx, prev_cy = previous_detections[index]
                if abs(cx - prev_cx) < 10 and abs(cy - prev_cy) < 10:
                    x1, y1, x2, y2 = prev_x1, prev_y1, prev_x2, prev_y2

            box_color = (255, 255, 255) if not is_violation else (0, 0, 255)
            cv2.rectangle(frame, (x1, y1), (x2, y2), box_color, 2)
            cv2.circle(frame, (cx, cy), 3, box_color, -1)

            if is_violation:
                if index not in violation_timers:
                    violation_timers[index] = datetime.now()
                elif datetime.now() - violation_timers[index] >= timedelta(seconds=3):
                    filename = os.path.join(capture_directory, f"pelanggaran_{index}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg")
                    cv2.imwrite(filename, frame[y1:y2, x1:x2])
                    print(f"Gambar pelanggaran disimpan: {filename}")
            else:
                violation_timers.pop(index, None)

        previous_detections = current_detections

        empty_slots = 0
        occupied_slots = 0
        violation_slots = 0

        for area_name, area_coords in areas.items():
            if violations[area_name] > 0:
                violation_slots += 1
            elif area_counts[area_name] > 0:
                occupied_slots += 1
            else:
                empty_slots += 1

        for area_index, (area_name, area_coords) in enumerate(areas.items(), start=1):
            color = (0, 0, 255) if violations[area_name] > 0 else (255, 0, 0) if area_counts[area_name] > 0 else (0, 255, 0)
            cv2.polylines(frame, [np.array(area_coords, np.int32)], True, color, 2)
            draw_vertical_lines(frame, area_coords)
            circle_center = (int(np.mean([coord[0] for coord in area_coords])), int(np.mean([coord[1] for coord in area_coords])) - 10)
            cv2.circle(frame, circle_center, 15, (255, 255, 255), -1)
            cv2.putText(frame, str(area_index), circle_center, cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 255), 1, cv2.LINE_AA)

        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()

        yield (b'--frame\r\n'
            b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/status')
def status():
    global empty_slots, occupied_slots, violation_slots
    return {
        "empty_slots": empty_slots,
        "occupied_slots": occupied_slots,
        "violation_slots": violation_slots
    }

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')



@app.route('/violations')
def get_violations():
    violations = []
    captures_dir = os.path.join("images", "captures")
    
    for filename in os.listdir(captures_dir):
        if filename.startswith('pelanggaran_'):
            parts = filename.replace('.jpg', '').split('_')
            violation_id = parts[1]
            timestamp = datetime.strptime('_'.join(parts[2:]), '%Y%m%d_%H%M%S')
            
            violations.append({
                'image': filename,
                'date': timestamp.strftime('%d %B %Y'),
                'description': 'Kendaraan parkir di luar Area.',
                'location': f'Area {violation_id}',
            })
    
    violations.sort(key=lambda x: datetime.strptime(x['date'], '%d %B %Y'), reverse=True)
    return jsonify(violations)

@app.route('/violations/<string:filename>', methods=['DELETE'])
def delete_violation(filename):
    file_path = os.path.join(capture_directory, filename)
    if os.path.exists(file_path):
        os.remove(file_path)
        return jsonify({"message": "Violation deleted successfully"}), 200
    else:
        return jsonify({"message": "Violation not found"}), 404

@app.route('/violations', methods=['DELETE'])
def delete_all_violations():
    try:
        for filename in os.listdir(capture_directory):
            if filename.startswith('pelanggaran_'):
                file_path = os.path.join(capture_directory, filename)
                os.remove(file_path)
        return jsonify({"message": "All violations deleted successfully"}), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500
    
@app.route('/images/captures/<path:filename>')
def serve_image(filename):
    return send_from_directory(os.path.join('images', 'captures'), filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=8080)