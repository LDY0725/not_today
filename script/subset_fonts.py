#!/usr/bin/env python3
"""
字体子集化脚本
从 Flutter 项目的 lib 目录提取所有使用的中文字符、英文字母和数字，
使用 pyftsubset 生成精简的字体文件。
"""

import os
import re
import sys
from pathlib import Path
from typing import Set, List

FONTS_DIR = Path("/Users/bytedance/Project/not_today/fonts")
LIB_DIR = Path("/Users/bytedance/Project/not_today/flutter_project/lib")
OUTPUT_DIR = Path("/Users/bytedance/Project/not_today/flutter_project/assets/fonts")


def extract_text_from_dart_files(lib_dir: Path) -> Set[str]:
    """从所有 dart 文件中提取使用的文字"""
    chinese_chars = set()
    english_chars = set()
    numbers = set()

    dart_files = list(lib_dir.rglob("*.dart"))

    for dart_file in dart_files:
        try:
            with open(dart_file, "r", encoding="utf-8") as f:
                content = f.read()

            for char in content:
                code = ord(char)

                if 0x4E00 <= code <= 0x9FFF:
                    chinese_chars.add(char)
                elif 0x61 <= code <= 0x7A:
                    english_chars.add(char.lower())
                elif 0x41 <= code <= 0x5A:
                    english_chars.add(char)
                elif 0x30 <= code <= 0x39:
                    numbers.add(char)

        except Exception as e:
            print(f"警告: 无法读取文件 {dart_file}: {e}")

    return chinese_chars, english_chars, numbers


def build_text_file(chinese_chars: Set[str], english_chars: Set[str], numbers: Set[str], output_path: Path) -> None:
    """将提取的文字保存到临时文本文件"""
    with open(output_path, "w", encoding="utf-8") as f:

        if chinese_chars:
            sorted_chinese = sorted(chinese_chars)
            f.write("".join(sorted_chinese))
            f.write("\n")

        if english_chars:
            sorted_english = sorted(english_chars)
            f.write("".join(sorted_english))
            f.write("\n")

        if numbers:
            sorted_numbers = sorted(numbers)
            f.write("".join(sorted_numbers))
            f.write("\n")

    print(f"文字已保存到: {output_path}")
    print(f"中文字符数量: {len(chinese_chars)}")
    print(f"英文字母数量: {len(english_chars)}")
    print(f"数字数量: {len(numbers)}")


def get_font_files(fonts_dir: Path) -> List[Path]:
    """获取所有字体文件"""
    if not fonts_dir.exists():
        print(f"错误: 字体目录不存在: {fonts_dir}")
        return []

    font_files = []
    for ext in ["*.ttf", "*.otf"]:
        font_files.extend(fonts_dir.glob(ext))

    if not font_files:
        print(f"警告: 在 {fonts_dir} 中未找到字体文件")
        return []

    return sorted(font_files)


def create_subset_font(font_path: Path, text_file: Path, output_dir: Path) -> bool:
    """使用 pyftsubset 创建字体子集"""
    try:
        import subprocess

        output_path = output_dir / f"{font_path.stem}.ttf"

        cmd = [
            "pyftsubset",
            str(font_path),
            f"--text-file={text_file}",
            f"--output-file={output_path}",
            "--no-subset-tables+=FFTM",
            "--no-subset-tables+=DSIG",
            "--layout-features+=*",
            "--glyph-names",
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print(f"✓ 生成子集字体: {output_path.name}")
            if output_path.exists():
                size_kb = output_path.stat().st_size / 1024
                print(f"  文件大小: {size_kb:.1f} KB")
            return True
        else:
            print(f"✗ 生成失败 {font_path.name}: {result.stderr}")
            return False

    except ImportError:
        print("错误: pyftsubset 未安装")
        print("请安装: pip install fonttools")
        return False
    except FileNotFoundError:
        print("错误: pyftsubset 命令未找到")
        print("请安装: pip install fonttools")
        return False


def create_flutter_font_manifest(output_dir: Path, font_files: List[Path]) -> None:
    """生成 Flutter 字体配置文件"""
    manifest_path = output_dir / "fonts.yaml"

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write("# Flutter 字体配置\n")
        f.write("# 由 subset_fonts.py 自动生成\n\n")

        for i, font_file in enumerate(font_files):
            font_name = font_file.stem.replace("NotoSerifSC-", "").lower()
            subset_name = f"subset_{font_file.stem}"

            f.write(f"fonts:\n")
            f.write(f"  - family: NotoSerifSC\n")
            f.write(f"    fonts:\n")
            f.write(f"      - asset: fonts/subset_{font_file.name}\n")
            f.write(f"        weight: {get_font_weight(font_name)}\n")


def get_font_weight(font_name: str) -> int:
    """根据字体名称获取字重"""
    weights = {
        "extralight": 200,
        "light": 300,
        "semilight": 350,
        "regular": 400,
        "medium": 500,
        "semibold": 600,
        "bold": 700,
        "extrabold": 800,
        "black": 900,
    }

    for key, value in weights.items():
        if key in font_name.lower():
            return value

    return 400


def main():
    print("=" * 50)
    print("字体子集化工具")
    print("=" * 50)

    if not FONTS_DIR.exists():
        print(f"错误: 字体目录不存在: {FONTS_DIR}")
        sys.exit(1)

    if not LIB_DIR.exists():
        print(f"错误: lib 目录不存在: {LIB_DIR}")
        sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"\n[1/4] 扫描 Dart 文件: {LIB_DIR}")
    chinese_chars, english_chars, numbers = extract_text_from_dart_files(LIB_DIR)

    if not chinese_chars and not english_chars and not numbers:
        print("错误: 未找到任何字符")
        sys.exit(1)

    print(f"\n[2/4] 保存字符集到临时文件")
    text_file = OUTPUT_DIR / "chars.txt"
    build_text_file(chinese_chars, english_chars, numbers, text_file)

    print(f"\n[3/4] 获取字体文件: {FONTS_DIR}")
    font_files = get_font_files(FONTS_DIR)

    if not font_files:
        print("错误: 未找到字体文件")
        sys.exit(1)

    print(f"找到 {len(font_files)} 个字体文件:")
    for font_file in font_files:
        size_kb = font_file.stat().st_size / 1024
        print(f"  - {font_file.name} ({size_kb:.1f} KB)")

    print(f"\n[4/4] 生成子集字体")

    success_count = 0
    for font_file in font_files:
        if create_subset_font(font_file, text_file, OUTPUT_DIR):
            success_count += 1

    print("\n" + "=" * 50)
    print(f"完成! 成功生成 {success_count}/{len(font_files)} 个子集字体")
    print(f"输出目录: {OUTPUT_DIR}")
    print("=" * 50)

    if text_file.exists():
        text_file.unlink()
        print(f"\n临时文件已清理: {text_file}")


if __name__ == "__main__":
    main()
