import os
import re
import subprocess

figma_dir = r"c:\Users\amado\OneDrive\Desktop\Soutenance ODK\Projet\mobile-hair-style\figma"
scratch_dir = r"C:\Users\amado\.gemini\antigravity-ide\brain\bbd70586-5781-4dd3-875d-588047e1e4d8\scratch"

edge_paths = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe"
]
browser = next((p for p in edge_paths if os.path.exists(p)), None)

targets = [
    ("Mes reclemmations.svg", "mes_reclamations_tous.png"),
    ("Mes reclemmations en attente.svg", "mes_reclamations_attente.png"),
    ("Mes reclemmations en cours.svg", "mes_reclamations_en_cours.png"),
    ("Mes reclemmations resolue.svg", "mes_reclamations_resolue.png"),
    ("Mes reclemmations rejetee.svg", "mes_reclamations_rejetee.png"),
    ("Details reclammation en attente.svg", "details_reclamation_attente.png"),
    ("Details reclammation en cours.svg", "details_reclamation_en_cours.png"),
    ("Details reclammation resolue.svg", "details_reclamation_resolue.png"),
    ("Details reclammation rejete.svg", "details_reclamation_rejete.png"),
    ("Nouvelle reclammation.svg", "nouvelle_reclamation.png"),
]

for svg_name, png_name in targets:
    svg_path = os.path.join(figma_dir, svg_name)
    out_png = os.path.join(scratch_dir, png_name)
    print(f"\n==================== {svg_name} ====================")
    if not os.path.exists(svg_path):
        print(f"File not found: {svg_path}")
        continue

    with open(svg_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    w_match = re.search(r'width="([^"]+)"', content)
    h_match = re.search(r'height="([^"]+)"', content)
    w_str = w_match.group(1) if w_match else '402'
    h_str = h_match.group(1) if h_match else '874'
    print(f"Width: {w_str}, Height: {h_str}")

    if browser:
        try:
            w_int = int(float(w_str))
            h_int = int(float(h_str))
        except:
            w_int, h_int = 402, 874
        cmd = [
            browser, "--headless", f"--screenshot={out_png}",
            f"--window-size={w_int},{h_int}", "--hide-scrollbars",
            f"file:///{svg_path.replace(os.sep, '/')}"
        ]
        subprocess.run(cmd, check=True)
        print(f"Rendered {png_name}: {os.path.exists(out_png)}")
