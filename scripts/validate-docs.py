#!/usr/bin/env python3
"""
Documentation Validation Script

Validates markdown files for:
- Broken internal links
- Missing images
- Invalid code blocks
- Inconsistent formatting
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple


def find_markdown_files(docs_dir: str = "docs") -> List[Path]:
    """Find all markdown files in the docs directory."""
    docs_path = Path(docs_dir)
    return list(docs_path.rglob("*.md"))


def validate_internal_links(md_file: Path, docs_dir: str = "docs") -> List[str]:
    """Validate internal links in a markdown file."""
    errors = []
    content = md_file.read_text(encoding="utf-8")
    
    # Find all markdown links: [text](link)
    link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
    links = re.findall(link_pattern, content)
    
    for text, link in links:
        # Skip external links
        if link.startswith(('http://', 'https://', 'mailto:', '#')):
            continue
        
        # Skip anchors within the same page
        if link.startswith('#'):
            continue
        
        # Remove anchor from link
        link_path = link.split('#')[0]
        
        if not link_path:
            continue
        
        # Resolve relative path
        if link_path.startswith('../'):
            target = (md_file.parent / link_path).resolve()
        elif link_path.startswith('./'):
            target = (md_file.parent / link_path[2:]).resolve()
        else:
            target = (md_file.parent / link_path).resolve()
        
        # Check if target exists
        if not target.exists():
            # Try adding .md extension
            if not str(target).endswith('.md'):
                target_md = Path(str(target) + '.md')
                if not target_md.exists():
                    errors.append(
                        f"Broken link in {md_file}: [{text}]({link}) -> {target} not found"
                    )
            else:
                errors.append(
                    f"Broken link in {md_file}: [{text}]({link}) -> {target} not found"
                )
    
    return errors


def validate_images(md_file: Path) -> List[str]:
    """Validate image references in a markdown file."""
    errors = []
    content = md_file.read_text(encoding="utf-8")
    
    # Find all image references: ![alt](path)
    image_pattern = r'!\[([^\]]*)\]\(([^)]+)\)'
    images = re.findall(image_pattern, content)
    
    for alt, path in images:
        # Skip external images
        if path.startswith(('http://', 'https://')):
            continue
        
        # Resolve relative path
        if path.startswith('../'):
            target = (md_file.parent / path).resolve()
        elif path.startswith('./'):
            target = (md_file.parent / path[2:]).resolve()
        else:
            target = (md_file.parent / path).resolve()
        
        # Check if image exists
        if not target.exists():
            errors.append(
                f"Missing image in {md_file}: ![{alt}]({path}) -> {target} not found"
            )
    
    return errors


def validate_code_blocks(md_file: Path) -> List[str]:
    """Validate code blocks in a markdown file."""
    errors = []
    content = md_file.read_text(encoding="utf-8")
    lines = content.split('\n')
    
    in_code_block = False
    code_block_start = 0
    fence_count = 0
    
    for i, line in enumerate(lines, 1):
        # Check for code fence
        if line.strip().startswith('```'):
            fence_count += 1
            if not in_code_block:
                in_code_block = True
                code_block_start = i
            else:
                in_code_block = False
    
    # Check for unclosed code blocks
    if fence_count % 2 != 0:
        errors.append(
            f"Unclosed code block in {md_file}: started at line {code_block_start}"
        )
    
    return errors


def validate_yaml_frontmatter(md_file: Path) -> List[str]:
    """Validate YAML frontmatter if present."""
    errors = []
    content = md_file.read_text(encoding="utf-8")
    
    # Check for YAML frontmatter
    if content.startswith('---\n'):
        parts = content.split('---\n', 2)
        if len(parts) < 3:
            errors.append(f"Incomplete YAML frontmatter in {md_file}")
        else:
            frontmatter = parts[1]
            # Basic validation - check for required fields
            if 'title:' not in frontmatter and md_file.name != 'index.md':
                errors.append(f"Missing title in frontmatter in {md_file}")
    
    return errors


def validate_headings(md_file: Path) -> List[str]:
    """Validate heading structure."""
    errors = []
    content = md_file.read_text(encoding="utf-8")
    lines = content.split('\n')
    
    heading_levels = []
    for i, line in enumerate(lines, 1):
        if line.startswith('#'):
            level = len(line.split()[0])
            heading_levels.append((i, level, line))
    
    # Check for heading level skips
    for i in range(1, len(heading_levels)):
        prev_line, prev_level, _ = heading_levels[i-1]
        curr_line, curr_level, curr_text = heading_levels[i]
        
        if curr_level > prev_level + 1:
            errors.append(
                f"Heading level skip in {md_file} at line {curr_line}: "
                f"jumped from H{prev_level} to H{curr_level}"
            )
    
    return errors


def main():
    """Main validation function."""
    print("🔍 Validating documentation...")
    print()
    
    docs_dir = "docs"
    md_files = find_markdown_files(docs_dir)
    
    print(f"Found {len(md_files)} markdown files")
    print()
    
    all_errors = []
    
    for md_file in md_files:
        print(f"Checking {md_file}...", end=" ")
        
        errors = []
        errors.extend(validate_internal_links(md_file, docs_dir))
        errors.extend(validate_images(md_file))
        errors.extend(validate_code_blocks(md_file))
        errors.extend(validate_yaml_frontmatter(md_file))
        errors.extend(validate_headings(md_file))
        
        if errors:
            print(f"❌ {len(errors)} error(s)")
            all_errors.extend(errors)
        else:
            print("✅")
    
    print()
    
    if all_errors:
        print(f"❌ Found {len(all_errors)} validation error(s):")
        print()
        for error in all_errors:
            print(f"  • {error}")
        print()
        sys.exit(1)
    else:
        print("✅ All documentation files are valid!")
        sys.exit(0)


if __name__ == "__main__":
    main()

