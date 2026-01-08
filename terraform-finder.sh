#!/bin/bash

# Script to find and report on Terraform projects, with special attention to Vultr/firewall configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Starting directory (default to current directory)
SEARCH_DIR="${1:-.}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Terraform Project Finder Report     ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Search started at: $(date)"
echo -e "Search directory: $(realpath "$SEARCH_DIR")\n"

# Find all directories containing Terraform files (excluding .terraform directories)
terraform_dirs=$(find "$SEARCH_DIR" -type f \( -name "*.tf" -o -name "*.tf.json" -o -name "*.tfvars" \) 2>/dev/null | grep -v "/.terraform/" | xargs -I {} dirname {} | sort -u)

if [ -z "$terraform_dirs" ]; then
    echo -e "${RED}No Terraform files found in $SEARCH_DIR${NC}"
    exit 1
fi

total_projects=$(echo "$terraform_dirs" | wc -l)
echo -e "${GREEN}Found $total_projects Terraform project(s)${NC}\n"

# Track if we found Vultr/firewall related projects
vultr_found=false

# Analyze each directory
project_num=0
for dir in $terraform_dirs; do
    project_num=$((project_num + 1))
    
    echo -e "${YELLOW}[$project_num/$total_projects] Project: $dir${NC}"
    echo "----------------------------------------"
    
    # Count Terraform files
    tf_count=$(find "$dir" -maxdepth 1 -name "*.tf" 2>/dev/null | wc -l)
    tfvars_count=$(find "$dir" -maxdepth 1 -name "*.tfvars" 2>/dev/null | wc -l)
    
    echo "  Terraform files: $tf_count .tf files, $tfvars_count .tfvars files"
    
    # Check for state files (indicates active/deployed infrastructure)
    if [ -f "$dir/terraform.tfstate" ] || [ -f "$dir/.terraform/terraform.tfstate" ]; then
        echo -e "  ${GREEN}✓ Has state file (deployed infrastructure)${NC}"
    fi
    
    # Check for .terraform directory (indicates initialized)
    if [ -d "$dir/.terraform" ]; then
        echo -e "  ${GREEN}✓ Initialized (.terraform exists)${NC}"
    fi
    
    # Look for provider information
    providers=$(grep -h "provider\s*\"" "$dir"/*.tf 2>/dev/null | sed 's/.*provider.*"\([^"]*\)".*/\1/' | sort -u | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$providers" ]; then
        echo "  Providers: $providers"
    fi
    
    # Check for Vultr or firewall-related content
    vultr_matches=$(grep -il "vultr" "$dir"/*.tf 2>/dev/null)
    firewall_matches=$(grep -il "firewall\|security_group\|ingress\|egress" "$dir"/*.tf 2>/dev/null)
    
    if [ -n "$vultr_matches" ] || [ -n "$firewall_matches" ]; then
        echo -e "  ${RED}★ POTENTIAL MATCH FOR YOUR SEARCH ★${NC}"
        vultr_found=true
        
        if [ -n "$vultr_matches" ]; then
            echo -e "  ${GREEN}Found 'vultr' in:${NC}"
            echo "$vultr_matches" | while read file; do
                echo "    - $(basename "$file")"
                # Show context lines with Vultr mentions
                grep -n -i "vultr" "$file" | head -3 | sed 's/^/      Line /'
            done
        fi
        
        if [ -n "$firewall_matches" ]; then
            echo -e "  ${GREEN}Found firewall/security rules in:${NC}"
            echo "$firewall_matches" | while read file; do
                basename_file=$(basename "$file")
                # Don't duplicate if already shown in vultr_matches
                if ! echo "$vultr_matches" | grep -q "$file"; then
                    echo "    - $basename_file"
                    # Show first few firewall-related lines
                    grep -n -i "firewall\|security_group" "$file" | head -2 | sed 's/^/      Line /'
                fi
            done
        fi
    fi
    
    # Show main resource types
    resources=$(grep -h "^resource\s*\"" "$dir"/*.tf 2>/dev/null | sed 's/resource.*"\([^"]*\)".*/\1/' | sort -u | head -5 | tr '\n' ', ' | sed 's/,$//')
    if [ -n "$resources" ]; then
        echo "  Main resources: $resources"
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}                SUMMARY                 ${NC}"
echo -e "${BLUE}========================================${NC}"

if [ "$vultr_found" = true ]; then
    echo -e "${GREEN}✓ Found potential Vultr/firewall Terraform projects!${NC}"
    echo -e "  Re-run with grep for more details:"
    echo -e "  ${YELLOW}grep -r \"vultr\" $SEARCH_DIR --include=\"*.tf\"${NC}"
else
    echo -e "${YELLOW}No obvious Vultr or firewall configurations found.${NC}"
    echo -e "You might want to:"
    echo -e "  1. Check for Ansible playbooks: ${YELLOW}find $SEARCH_DIR -name \"*.yml\" -o -name \"*.yaml\" | xargs grep -l \"vultr\"${NC}"
    echo -e "  2. Search for backup/archived directories"
    echo -e "  3. Check your version control history"
    echo -e "  4. Look for .tfvars files that might reference Vultr: ${YELLOW}find $SEARCH_DIR -name \"*.tfvars\" | xargs grep -l \"vultr\"${NC}"
fi

echo -e "\nSearch completed at: $(date)"
