# Dangerfile
# PR Review automation for CoinGecko SDK

# MARK: - Basic PR Checks
# Ensure PR has a description
if github.pr_body.length < 10
  warn "Please add a more detailed description to your PR."
end

# Ensure PR has a proper title
if github.pr_title.length < 5
  fail "Please add a more descriptive title to your PR."
end

# Check if PR is work in progress
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# MARK: - File Changes Analysis
added_files = git.added_files
modified_files = git.modified_files
deleted_files = git.deleted_files

# Big PR check
if (added_files + modified_files - %w(Dangerfile)).size > 20
  warn "This PR seems quite large. Consider breaking it down into smaller PRs for easier review."
end

# MARK: - Swift Code Analysis
swift_files = (added_files + modified_files).select { |file| file.end_with?('.swift') }

if swift_files.any?
  message "This PR modifies #{swift_files.count} Swift file(s): #{swift_files.join(', ')}"
  
  # SwiftLint check
  swiftlint.config_file = '.swiftlint.yml'
  swiftlint.directory = "Sources"
  swiftlint.lint_files inline_mode: true
  
  # Check for TODO/FIXME
  swift_files.each do |file|
    next unless File.exist?(file)
    
    File.foreach(file).with_index do |line, index|
      if line.include?('TODO') || line.include?('FIXME')
        warn("#{file}:#{index + 1} contains TODO/FIXME", file: file, line: index + 1)
      end
    end
  end
end

# MARK: - Package.swift Changes
if modified_files.include?('Package.swift')
  warn "Package.swift has been modified. Please ensure version compatibility and update documentation if needed."
end

# MARK: - Test Coverage
test_files = (added_files + modified_files).select { |file| file.include?('Test') }

if swift_files.any? && test_files.empty?
  warn "You've added/modified Swift files but no tests. Consider adding tests for better coverage."
end

# MARK: - Live API Tests
live_api_test_files = (added_files + modified_files).select { |file| 
  file.include?('LiveAPITests.swift') || file.include?('LiveAPI') 
}

if live_api_test_files.any?
  warn "🔴 Live API tests have been modified: #{live_api_test_files.join(', ')}. These tests make real API calls and should be reviewed carefully."
  message "Please ensure:"
  message "• API keys and sensitive data are properly handled"
  message "• Tests don't exceed API rate limits"
  message "• Tests can handle API downtime gracefully"
  message "• Mock alternatives are available for CI/CD pipeline"
end

# Check if LiveAPITests.swift is being added for the first time
if added_files.include?('LiveAPITests.swift')
  message "🆕 New LiveAPITests.swift file detected. Make sure it follows the project's testing guidelines."
end

# If source files changed but LiveAPITests.swift wasn't updated
api_source_files = swift_files.select { |file| 
  file.include?('API') && !file.include?('Test') 
}

if api_source_files.any? && !live_api_test_files.any?
  message "💡 API source files were modified but LiveAPITests.swift wasn't updated. Consider if live tests need updates."
end

# MARK: - Documentation
docs_modified = (added_files + modified_files).select { |file| 
  file.end_with?('.md') || file.include?('README') || file.include?('CHANGELOG')
}

if swift_files.any? && docs_modified.empty?
  message "Consider updating documentation if your changes affect the public API."
end

# MARK: - API Changes
api_files = swift_files.select { |file| 
  file.include?('API.swift') || 
  file.include?('Client/') ||
  file.start_with?('Sources/Client/')
}

if api_files.any?
  warn "⚠️  Public API changes detected. Please ensure backward compatibility and update version accordingly."
end

# MARK: - Core Changes
core_files = swift_files.select { |file| file.start_with?('Sources/Core/') }

if core_files.any?
  message "🔧 Core framework changes detected. These affect all components."
end

# MARK: - Network Changes  
network_files = swift_files.select { |file| file.start_with?('Sources/Network/') }

if network_files.any?
  message "🌐 Network layer changes detected. Ensure error handling and retry logic are properly tested."
end

# MARK: - Configuration Changes
config_files = (added_files + modified_files).select { |file|
  file.include?('Configuration') ||
  file.include?('Environment') ||
  file.include?('.yml') ||
  file.include?('.yaml')
}

if config_files.any?
  warn "⚙️  Configuration files changed: #{config_files.join(', ')}. Double-check all environments."
end

# MARK: - Dependency Changes
if modified_files.include?('Gemfile') || modified_files.include?('Package.swift')
  message "📦 Dependencies have been updated. Make sure to update lockfiles and test thoroughly."
end

# MARK: - CI/CD Changes
ci_files = (added_files + modified_files).select { |file|
  file.start_with?('.github/') ||
  file.include?('Fastfile') ||
  file.include?('Dangerfile')
}

if ci_files.any?
  warn "🤖 CI/CD configuration changed. Test the pipeline thoroughly before merging."
end

# MARK: - Encourage Good Practices
if swift_files.any?
  message "Thank you for contributing to CoinGecko SDK! 🚀"
  
  # Check for common patterns
  swift_files.each do |file|
    next unless File.exist?(file)
    
    content = File.read(file)
    
    # Encourage documentation
    if content.include?('public ') && !content.include?('///')
      message "Consider adding documentation comments (///) to public APIs in #{file}"
    end
    
    # Check for force unwrapping
    if content.include?('!')
      warn "#{file} contains force unwrapping (!). Consider using safe unwrapping or proper error handling."
    end
  end
end