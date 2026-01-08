package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

type cmdCount struct {
	cmd   string
	count int
}

type AnalysisResult struct {
	CmdCounts        map[string]int
	MultiCmdPatterns map[string]int
}

var skipCmds = map[string]bool{
	"cd": true, "ls": true, "ll": true, "la": true,
	"pwd": true, "clear": true, "exit": true, "z": true,
}

var timestampRe = regexp.MustCompile(`^: \d+:\d+;`)

func main() {
	homeDir, _ := os.UserHomeDir()
	histFile := filepath.Join(homeDir, ".zsh_history")

	file, err := os.Open(histFile)
	if err != nil {
		fmt.Println("Error opening history file:", err)
		os.Exit(1)
	}
	defer file.Close()

	result := analyzeHistory(file, 1000)
	printResults(result)
}

func analyzeHistory(r io.ReadSeeker, lastN int) AnalysisResult {
	result := AnalysisResult{
		CmdCounts:        make(map[string]int),
		MultiCmdPatterns: make(map[string]int),
	}

	// Count total lines
	scanner := bufio.NewScanner(r)
	lineCount := 0
	for scanner.Scan() {
		lineCount++
	}

	// Reset and read last N lines
	r.Seek(0, 0)
	scanner = bufio.NewScanner(r)
	skipLines := lineCount - lastN
	if skipLines < 0 {
		skipLines = 0
	}

	currentLine := 0
	for scanner.Scan() {
		currentLine++
		if currentLine <= skipLines {
			continue
		}

		line := parseLine(scanner.Text())
		if line == "" {
			continue
		}

		processLine(line, &result)
	}

	return result
}

func parseLine(raw string) string {
	line := timestampRe.ReplaceAllString(raw, "")
	return strings.TrimSpace(line)
}

func processLine(line string, result *AnalysisResult) {
	parts := strings.Fields(line)
	if len(parts) == 0 {
		return
	}

	baseCmd := parts[0]

	if skipCmds[baseCmd] {
		return
	}

	// Track command patterns
	result.CmdCounts[baseCmd]++

	// Track multi-command patterns (&&, |)
	if strings.Contains(line, "&&") || strings.Contains(line, "|") {
		pattern := normalizePattern(line)
		if pattern != "" {
			result.MultiCmdPatterns[pattern]++
		}
	}

	// Track specific command combinations
	if len(parts) >= 2 {
		combo := parts[0] + " " + parts[1]
		result.CmdCounts[combo]++
	}
}

func normalizePattern(line string) string {
	parts := strings.Split(line, "&&")
	if len(parts) < 2 {
		parts = strings.Split(line, "|")
	}

	var cmds []string
	for _, p := range parts {
		fields := strings.Fields(strings.TrimSpace(p))
		if len(fields) > 0 {
			cmds = append(cmds, fields[0])
		}
	}

	if len(cmds) >= 2 {
		return strings.Join(cmds, " -> ")
	}
	return ""
}

func analyzeSuggestions(cmdCounts map[string]int) []string {
	var suggestions []string

	if cmdCounts["docker"] >= 5 || cmdCounts["docker compose"] >= 3 {
		suggestions = append(suggestions, "Docker cleanup script (prune images, containers, volumes)")
	}

	if cmdCounts["git"] >= 10 {
		suggestions = append(suggestions, "Git workflow scripts (branch cleanup, sync fork, etc.)")
	}

	if cmdCounts["kubectl"] >= 5 || cmdCounts["k"] >= 5 {
		suggestions = append(suggestions, "K8s helper scripts (get logs, exec into pod, port-forward)")
	}

	if cmdCounts["ansible-playbook"] >= 3 {
		suggestions = append(suggestions, "Ansible runner wrapper with common options")
	}

	if cmdCounts["npm"] >= 5 || cmdCounts["pnpm"] >= 5 {
		suggestions = append(suggestions, "Node project bootstrap script")
	}

	if cmdCounts["poetry"] >= 3 || cmdCounts["pyenv"] >= 3 {
		suggestions = append(suggestions, "Python project bootstrap script")
	}

	if cmdCounts["terraform"] >= 3 || cmdCounts["tf"] >= 3 {
		suggestions = append(suggestions, "Terraform workspace manager script")
	}

	if cmdCounts["gh"] >= 5 {
		suggestions = append(suggestions, "GitHub CLI workflow scripts (PR templates, issue management)")
	}

	if cmdCounts["ssh"] >= 5 {
		suggestions = append(suggestions, "SSH connection manager/bookmarks script")
	}

	if cmdCounts["curl"] >= 5 {
		suggestions = append(suggestions, "API testing helper script")
	}

	if len(suggestions) == 0 {
		suggestions = append(suggestions, "No obvious patterns detected - history may be too varied")
	}

	return suggestions
}

func printResults(result AnalysisResult) {
	// Sort and display top commands
	var sorted []cmdCount
	for cmd, count := range result.CmdCounts {
		if count >= 3 {
			sorted = append(sorted, cmdCount{cmd, count})
		}
	}
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].count > sorted[j].count
	})

	fmt.Println("=== TOP COMMANDS (used 3+ times) ===")
	fmt.Println()
	for i, c := range sorted {
		if i >= 40 {
			break
		}
		fmt.Printf("%4d  %s\n", c.count, c.cmd)
	}

	// Show multi-command patterns
	fmt.Println()
	fmt.Println("=== MULTI-COMMAND PATTERNS (potential scripts) ===")
	fmt.Println()

	var multiSorted []cmdCount
	for pattern, count := range result.MultiCmdPatterns {
		if count >= 2 {
			multiSorted = append(multiSorted, cmdCount{pattern, count})
		}
	}
	sort.Slice(multiSorted, func(i, j int) bool {
		return multiSorted[i].count > multiSorted[j].count
	})

	for i, c := range multiSorted {
		if i >= 20 {
			break
		}
		fmt.Printf("%4d  %s\n", c.count, c.cmd)
	}

	// Suggestions
	fmt.Println()
	fmt.Println("=== SCRIPT SUGGESTIONS ===")
	fmt.Println()

	suggestions := analyzeSuggestions(result.CmdCounts)
	for _, s := range suggestions {
		fmt.Println("- " + s)
	}
}
