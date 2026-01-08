package main

import (
	"strings"
	"testing"
)

func TestParseLine(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "with zsh timestamp",
			input:    ": 1766243818:0;brew update",
			expected: "brew update",
		},
		{
			name:     "without timestamp",
			input:    "git status",
			expected: "git status",
		},
		{
			name:     "with whitespace",
			input:    "  docker ps  ",
			expected: "docker ps",
		},
		{
			name:     "empty line",
			input:    "",
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := parseLine(tt.input)
			if result != tt.expected {
				t.Errorf("parseLine(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestNormalizePattern(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "double ampersand",
			input:    "git add . && git commit -m 'test'",
			expected: "git -> git",
		},
		{
			name:     "pipe",
			input:    "cat file.txt | grep error",
			expected: "cat -> grep",
		},
		{
			name:     "triple command",
			input:    "mkdir foo && cd foo && git init",
			expected: "mkdir -> cd -> git",
		},
		{
			name:     "single command",
			input:    "ls -la",
			expected: "",
		},
		{
			name:     "empty",
			input:    "",
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := normalizePattern(tt.input)
			if result != tt.expected {
				t.Errorf("normalizePattern(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestProcessLine(t *testing.T) {
	tests := []struct {
		name              string
		input             string
		expectedCmd       string
		expectedCount     int
		expectedCombo     string
		expectedComboCount int
	}{
		{
			name:              "simple command",
			input:             "docker ps",
			expectedCmd:       "docker",
			expectedCount:     1,
			expectedCombo:     "docker ps",
			expectedComboCount: 1,
		},
		{
			name:          "skipped command",
			input:         "cd /home",
			expectedCmd:   "cd",
			expectedCount: 0, // should be skipped
		},
		{
			name:          "single word command",
			input:         "htop",
			expectedCmd:   "htop",
			expectedCount: 1,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := &AnalysisResult{
				CmdCounts:        make(map[string]int),
				MultiCmdPatterns: make(map[string]int),
			}
			processLine(tt.input, result)

			if result.CmdCounts[tt.expectedCmd] != tt.expectedCount {
				t.Errorf("CmdCounts[%q] = %d, want %d", tt.expectedCmd, result.CmdCounts[tt.expectedCmd], tt.expectedCount)
			}

			if tt.expectedCombo != "" && result.CmdCounts[tt.expectedCombo] != tt.expectedComboCount {
				t.Errorf("CmdCounts[%q] = %d, want %d", tt.expectedCombo, result.CmdCounts[tt.expectedCombo], tt.expectedComboCount)
			}
		})
	}
}

func TestProcessLineMultiCmd(t *testing.T) {
	result := &AnalysisResult{
		CmdCounts:        make(map[string]int),
		MultiCmdPatterns: make(map[string]int),
	}

	processLine("brew update && brew upgrade", result)

	if result.MultiCmdPatterns["brew -> brew"] != 1 {
		t.Errorf("MultiCmdPatterns[\"brew -> brew\"] = %d, want 1", result.MultiCmdPatterns["brew -> brew"])
	}
}

func TestAnalyzeSuggestions(t *testing.T) {
	tests := []struct {
		name        string
		cmdCounts   map[string]int
		shouldFind  string
		shouldNotFind string
	}{
		{
			name:       "docker suggestion",
			cmdCounts:  map[string]int{"docker": 5},
			shouldFind: "Docker cleanup script",
		},
		{
			name:       "docker compose suggestion",
			cmdCounts:  map[string]int{"docker compose": 3},
			shouldFind: "Docker cleanup script",
		},
		{
			name:       "git suggestion",
			cmdCounts:  map[string]int{"git": 10},
			shouldFind: "Git workflow scripts",
		},
		{
			name:       "git below threshold",
			cmdCounts:  map[string]int{"git": 9},
			shouldNotFind: "Git workflow scripts",
		},
		{
			name:       "kubectl suggestion",
			cmdCounts:  map[string]int{"kubectl": 5},
			shouldFind: "K8s helper scripts",
		},
		{
			name:       "k alias suggestion",
			cmdCounts:  map[string]int{"k": 5},
			shouldFind: "K8s helper scripts",
		},
		{
			name:       "poetry suggestion",
			cmdCounts:  map[string]int{"poetry": 3},
			shouldFind: "Python project bootstrap",
		},
		{
			name:       "no patterns",
			cmdCounts:  map[string]int{"foo": 1, "bar": 2},
			shouldFind: "No obvious patterns detected",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			suggestions := analyzeSuggestions(tt.cmdCounts)
			joined := strings.Join(suggestions, " ")

			if tt.shouldFind != "" && !strings.Contains(joined, tt.shouldFind) {
				t.Errorf("analyzeSuggestions() should contain %q, got %v", tt.shouldFind, suggestions)
			}

			if tt.shouldNotFind != "" && strings.Contains(joined, tt.shouldNotFind) {
				t.Errorf("analyzeSuggestions() should not contain %q, got %v", tt.shouldNotFind, suggestions)
			}
		})
	}
}

func TestAnalyzeHistory(t *testing.T) {
	historyData := `: 1766243818:0;git status
: 1766243819:0;git add .
: 1766243820:0;git commit -m "test"
: 1766243821:0;docker ps
: 1766243822:0;docker ps
: 1766243823:0;cd /home
: 1766243824:0;ls -la
: 1766243825:0;brew update && brew upgrade
`

	reader := strings.NewReader(historyData)
	result := analyzeHistory(reader, 1000)

	// git should be counted 3 times
	if result.CmdCounts["git"] != 3 {
		t.Errorf("CmdCounts[\"git\"] = %d, want 3", result.CmdCounts["git"])
	}

	// docker should be counted 2 times
	if result.CmdCounts["docker"] != 2 {
		t.Errorf("CmdCounts[\"docker\"] = %d, want 2", result.CmdCounts["docker"])
	}

	// cd should be skipped
	if result.CmdCounts["cd"] != 0 {
		t.Errorf("CmdCounts[\"cd\"] = %d, want 0 (should be skipped)", result.CmdCounts["cd"])
	}

	// ls should be skipped
	if result.CmdCounts["ls"] != 0 {
		t.Errorf("CmdCounts[\"ls\"] = %d, want 0 (should be skipped)", result.CmdCounts["ls"])
	}

	// multi-cmd pattern should be detected
	if result.MultiCmdPatterns["brew -> brew"] != 1 {
		t.Errorf("MultiCmdPatterns[\"brew -> brew\"] = %d, want 1", result.MultiCmdPatterns["brew -> brew"])
	}
}

func TestAnalyzeHistoryLastN(t *testing.T) {
	// Create history with 10 lines
	historyData := `: 1:0;cmd1
: 2:0;cmd2
: 3:0;cmd3
: 4:0;cmd4
: 5:0;cmd5
: 6:0;cmd6
: 7:0;cmd7
: 8:0;cmd8
: 9:0;cmd9
: 10:0;cmd10
`

	reader := strings.NewReader(historyData)
	result := analyzeHistory(reader, 3)

	// Should only process last 3 commands (cmd8, cmd9, cmd10)
	if result.CmdCounts["cmd1"] != 0 {
		t.Errorf("cmd1 should not be counted when lastN=3")
	}

	if result.CmdCounts["cmd10"] != 1 {
		t.Errorf("cmd10 should be counted when lastN=3")
	}
}
