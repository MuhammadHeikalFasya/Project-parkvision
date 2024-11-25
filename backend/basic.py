import cv2
import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta
from ultralytics import YOLO

# Memuat model YOLOv8
model = YOLO('yolov8s.pt')

# Fungsi untuk menangkap nilai RGB saat mouse bergerak
def RGB(event, x, y, flags, param):
    if event == cv2.EVENT_MOUSEMOVE:
        colorsBGR = [x, y]
        print(colorsBGR)

# Mengatur window dan fungsi callback untuk menampilkan nilai RGB saat mouse bergerak
cv2.namedWindow('RGB')
cv2.setMouseCallback('RGB', RGB)

# Inisialisasi pengambilan video dari file
cap = cv2.VideoCapture('Dataset parkir v2.mp4')

# Memuat daftar kelas dari dataset COCO
with open("coco.txt", "r") as my_file:
    class_list = my_file.read().split("\n")

# Mendefinisikan area parkir dengan koordinat masing-masing
areas = {
    "area1": [(210, 173), (19, 340), (149, 319), (315, 169)],
    "area2": [(330, 168), (172, 310), (313, 284), (450, 150)],
    "area3": [(467, 151), (333, 285), (473, 265), (578, 142)],
    "area4": [(595, 138), (492, 263), (624, 247), (693, 136)],
    "area5": [(706, 134), (640, 246), (752, 230), (787, 136)],
    "area6": [(798, 138), (766, 230), (856, 219), (871, 136)],
    "area7": [(881, 132), (868, 218), (938, 212), (953, 136)],
}

# Simpan status objek
previous_detections = {}
violation_timers = {}  # Menyimpan waktu pelanggaran setiap objek
capture_directory = "captures"  # Direktori untuk menyimpan gambar pelanggaran

# Membuat direktori penyimpanan jika belum ada
os.makedirs(capture_directory, exist_ok=True)

# Fungsi untuk mendapatkan posisi garis vertikal berdasarkan area dan jarak antar garis
def get_line_positions(area_coords, line_spacing=0.35):
    coords = np.array(area_coords, np.float32)
    width_top = coords[3][0] - coords[0][0]
    width_bottom = coords[2][0] - coords[1][0]
    
    # Mendefinisikan posisi garis berdasarkan rasio
    positions = [line_spacing, 1 - line_spacing]
    lines = []
    
    for ratio in positions:
        top_x = coords[0][0] + ratio * width_top
        bottom_x = coords[1][0] + ratio * width_bottom
        lines.append((top_x, bottom_x))
    
    return lines

# Fungsi untuk memeriksa apakah objek berada di antara dua garis vertikal dalam suatu area
def is_between_lines(point, area_coords, line_positions):
    cx, cy = point  # Koordinat x dan y dari titik (objek)
    coords = np.array(area_coords, np.float32)
    
    # Mendapatkan posisi tengah y di bagian atas dan bawah area
    top_y = (coords[0][1] + coords[3][1]) / 2
    bottom_y = (coords[1][1] + coords[2][1]) / 2
    
    # Menginterpolasi posisi x yang diizinkan berdasarkan posisi y
    ratio = (cy - top_y) / (bottom_y - top_y)
    left_line_x = line_positions[0][0] + ratio * (line_positions[0][1] - line_positions[0][0])
    right_line_x = line_positions[1][0] + ratio * (line_positions[1][1] - line_positions[1][0])
    
    # Mengecek apakah titik berada di antara kedua garis
    return left_line_x <= cx <= right_line_x

# Fungsi untuk menggambar garis vertikal pada setiap area parkir
def draw_vertical_lines(frame, area_coords, line_spacing=0.35):
    coords = np.array(area_coords, np.float32)
    top_y = (coords[0][1] + coords[3][1]) / 2
    bottom_y = (coords[1][1] + coords[2][1]) / 2
    width_top = coords[3][0] - coords[0][0]
    width_bottom = coords[2][0] - coords[1][0]
    
    # Mendefinisikan posisi garis vertikal
    positions = [line_spacing, 1 - line_spacing]
    
    for ratio in positions:
        top_x = coords[0][0] + ratio * width_top
        bottom_x = coords[1][0] + ratio * width_bottom
        start_point = (int(top_x), int(top_y))
        end_point = (int(bottom_x), int(bottom_y))
        cv2.line(frame, start_point, end_point, (0, 255, 255), 2)  # Menggambar garis dengan warna kuning

# Loop utama untuk membaca frame dari video
while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.resize(frame, (1020, 500))  # Ubah ukuran frame
    results = model.predict(frame, verbose=False)  # Deteksi objek menggunakan model YOLO
    detections = pd.DataFrame(results[0].boxes.data).astype("float")  # Konversi hasil deteksi ke DataFrame
    area_counts = {area_name: 0 for area_name in areas}  # Menghitung objek di setiap area
    violations = {area_name: 0 for area_name in areas}  # Menghitung pelanggaran di setiap area

    # Loop untuk setiap deteksi objek
    current_detections = {}
    for index, row in detections.iterrows():
        x1, y1, x2, y2 = int(row[0]), int(row[1]), int(row[2]), int(row[3])
        class_id = int(row[5])
        class_name = class_list[class_id]

        if class_name in ["suitcase", "person", "car"]:
            cx, cy = (x1 + x2) // 2, (y1 + y2) // 2  # Mendapatkan pusat objek
            is_inside_area = False
            is_violation = True  # Default objek dianggap melanggar jika di luar garis

            # Memeriksa apakah objek berada di dalam area tertentu
            for area_name, area_coords in areas.items():
                if cv2.pointPolygonTest(np.array(area_coords, np.int32), (cx, cy), False) >= 0:
                    area_counts[area_name] += 1
                    is_inside_area = True

                    # Memeriksa apakah objek berada di antara garis vertikal dalam area
                    line_positions = get_line_positions(area_coords, line_spacing=0.35)
                    if is_between_lines((cx, cy), area_coords, line_positions):
                        is_violation = False  # Tidak dianggap melanggar jika berada di antara garis

                    # Menyimpan deteksi saat ini untuk pembaruan stabil
                    current_detections[index] = (x1, y1, x2, y2, is_violation, cx, cy)

                    # Menambah jumlah pelanggaran jika terdapat pelanggaran di area tersebut
                    if is_violation:
                        violations[area_name] += 1
                    break

            # Jika objek di luar area parkir
            if not is_inside_area:
                current_detections[index] = (x1, y1, x2, y2, True, cx, cy)

    # Mengupdate kotak deteksi berdasarkan status sebelumnya
    for index, (x1, y1, x2, y2, is_violation, cx, cy) in current_detections.items():
        if index in previous_detections:
            # Ambil posisi sebelumnya
            prev_x1, prev_y1, prev_x2, prev_y2, prev_is_violation, prev_cx, prev_cy = previous_detections[index]

            # Cek apakah objek masih terdeteksi dalam jarak yang dapat diterima
            if abs(cx - prev_cx) < 10 and abs(cy - prev_cy) < 10:
                x1, y1, x2, y2 = prev_x1, prev_y1, prev_x2, prev_y2  # Gunakan posisi sebelumnya jika stabil

        # Menentukan warna kotak berdasarkan pelanggaran
        box_color = (255, 255, 255) if not is_violation else (0, 0, 255)  # Putih untuk tidak melanggar, merah untuk melanggar
        cv2.rectangle(frame, (x1, y1), (x2, y2), box_color, 2)
        cv2.circle(frame, (cx, cy), 3, box_color, -1)

        # Menyimpan gambar jika terjadi pelanggaran selama lebih dari 3 detik
        if is_violation:
            if index not in violation_timers:
                violation_timers[index] = datetime.now()  # Mulai timer pelanggaran
            elif datetime.now() - violation_timers[index] >= timedelta(seconds=3):
                # Simpan gambar pelanggaran
                filename = f"{capture_directory}/pelanggaran_{index}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
                cv2.imwrite(filename, frame[y1:y2, x1:x2])
                print(f"Gambar pelanggaran disimpan: {filename}")
        else:
            violation_timers.pop(index, None)  # Reset timer jika tidak ada pelanggaran

    # Simpan deteksi saat ini untuk pembaruan di frame berikutnya
    previous_detections = current_detections

    # Menggambar area parkir
    for area_index, (area_name, area_coords) in enumerate(areas.items(), start=1):
        # Menentukan status blok
        if violations[area_name] > 0:
            color = (0, 0, 255)  # Merah: ada pelanggaran
            status = "melanggar"
        elif area_counts[area_name] > 0:
            color = (255, 0, 0)  # Biru: area terisi
            status = "terisi"
        else:
            color = (0, 255, 0)  # Hijau: area kosong
            status = "kosong"
        
        # Menggambar batas area
        cv2.polylines(frame, [np.array(area_coords, np.int32)], True, color, 2)

        # Menggambar garis vertikal di area parkir
        draw_vertical_lines(frame, area_coords)

        # Menambahkan lingkaran dan teks untuk menunjukkan nomor area
        circle_center = (int(np.mean([coord[0] for coord in area_coords])), int(np.mean([coord[1] for coord in area_coords])) - 10)
        cv2.circle(frame, circle_center, 15, (255, 255, 255), -1)  # Lingkaran putih
        cv2.putText(frame, str(area_index), circle_center, cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 255), 1, cv2.LINE_AA, bottomLeftOrigin=False)  # Teks merah di tengah lingkaran

        # Menampilkan status area di terminal
        print(f'{area_name} status: {status}')

    # Menghitung total pelanggaran
    total_violations = sum(violations.values())

    # Menampilkan total pelanggaran di bagian bawah frame
    cv2.putText(frame, f'Total Pelanggaran: {total_violations}', (10, 480),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)

    # Menampilkan blok yang melanggar
    violation_details = ', '.join([f'{area_name} ({violations[area_name]})' for area_name in areas if violations[area_name] > 0])
    cv2.putText(frame, f'Pelanggaran: {violation_details}', (10, 450),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)

    # Menampilkan frame dengan anotasi
    cv2.imshow("RGB", frame)

    # Keluar jika tombol 'Esc' ditekan
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()
