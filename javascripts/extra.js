// Custom JavaScript for Qiskit Operator documentation

document.addEventListener('DOMContentLoaded', function() {
  // Add copy button functionality for code blocks
  const codeBlocks = document.querySelectorAll('pre code');
  
  codeBlocks.forEach(function(codeBlock) {
    // Add a copy button
    const button = document.createElement('button');
    button.className = 'md-clipboard md-icon';
    button.title = 'Copy to clipboard';
    button.innerHTML = '📋';
    
    button.addEventListener('click', function() {
      const code = codeBlock.innerText;
      navigator.clipboard.writeText(code).then(function() {
        button.innerHTML = '✓';
        setTimeout(function() {
          button.innerHTML = '📋';
        }, 2000);
      });
    });
    
    codeBlock.parentNode.insertBefore(button, codeBlock);
  });

  // Add quantum animation to main title
  const mainTitle = document.querySelector('.md-header__title');
  if (mainTitle) {
    mainTitle.style.transition = 'all 0.3s ease';
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });

  // Add external link indicators
  document.querySelectorAll('a[href^="http"]').forEach(link => {
    if (!link.hostname.includes(window.location.hostname)) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });

  // Cost calculator helper
  window.estimateQuantumCost = function(shots, qubits, backend) {
    const baseRate = backend === 'simulator' ? 0 : 1.60 / 60; // $1.60 per minute
    const estimatedTime = (shots * qubits * 0.001); // rough estimate in seconds
    return (estimatedTime * baseRate).toFixed(2);
  };

  // Add version checker
  const checkVersion = async function() {
    try {
      const response = await fetch('https://api.github.com/repos/quantum-operator/qiskit-operator/releases/latest');
      const data = await response.json();
      const latestVersion = data.tag_name;
      
      // Display version info if available
      const versionInfo = document.querySelector('.md-header__version');
      if (versionInfo) {
        versionInfo.innerHTML = `Latest: ${latestVersion}`;
      }
    } catch (error) {
      console.log('Could not fetch version info');
    }
  };

  // Uncomment to enable version checking
  // checkVersion();

  // Add dark mode toggle enhancement
  const darkModeToggle = document.querySelector('[data-md-color-scheme]');
  if (darkModeToggle) {
    darkModeToggle.addEventListener('click', function() {
      localStorage.setItem('preferredTheme', this.dataset.mdColorScheme);
    });
  }

  // Analytics helper for tracking popular pages
  window.trackPageView = function(pageName) {
    // Add your analytics tracking code here
    console.log('Page viewed:', pageName);
  };

  // Initialize tooltips
  const tooltips = document.querySelectorAll('[data-tooltip]');
  tooltips.forEach(element => {
    element.addEventListener('mouseenter', function() {
      const tooltip = this.getAttribute('data-tooltip');
      // Add tooltip display logic
    });
  });
});

// Utility function for formatting quantum results
window.formatQuantumResults = function(counts) {
  if (typeof counts === 'string') {
    counts = JSON.parse(counts);
  }
  
  const total = Object.values(counts).reduce((a, b) => a + b, 0);
  const formatted = Object.entries(counts)
    .map(([state, count]) => ({
      state,
      count,
      probability: (count / total * 100).toFixed(2)
    }))
    .sort((a, b) => b.count - a.count);
  
  return formatted;
};

// Helper for generating kubectl commands
window.generateKubectlCommand = function(operation, resource, name, namespace) {
  const ns = namespace ? `-n ${namespace}` : '';
  return `kubectl ${operation} ${resource} ${name} ${ns}`.trim();
};

