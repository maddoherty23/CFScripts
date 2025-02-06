// Star Rating Widget with Lazy Loading & Customization
class StarRatingWidget {
  constructor(productId, position = 'bottom-right') {
    if (document.getElementById('star-rating-widget')) return; // Prevent duplicates

    this.productId = productId;
    this.position = position;
    this.apiUrl = document.currentScript.dataset.origin || 'https://beautiful-basbousa-5ba71c.netlify.app';
    this.container = null;
    this.lazyLoad = true; // Enable lazy loading
    this.darkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    this.init();
  }

  async init() {
    try {
      console.log('Initializing widget for product:', this.productId);
      if (this.lazyLoad) {
        this.lazyLoadWidget();
      } else {
        this.render();
      }
    } catch (error) {
      console.error('Failed to initialize star rating widget:', error);
    }
  }

  lazyLoadWidget() {
    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            this.render();
            observer.disconnect();
          }
        });
      });
      observer.observe(document.body);
    } else {
      this.render(); // Fallback for older browsers
    }
  }

  render() {
    this.container = document.createElement('div');
    this.container.id = 'star-rating-widget';
    this.container.className = `star-rating-widget star-rating-widget--${this.position}`;

    // Apply inline styles for dynamic positioning
    Object.assign(this.container.style, {
      position: 'fixed',
      zIndex: '9999',
      cursor: 'pointer',
      ...this.getPositionStyles()
    });

    // Create and append the iframe
    const iframe = document.createElement('iframe');
    iframe.src = `${this.apiUrl}/embed/star-rating/${this.productId}?theme=${this.darkMode ? 'dark' : 'light'}`;
    iframe.style.border = 'none';
    iframe.style.width = '200px';
    iframe.style.height = '50px';
    iframe.title = 'Product Rating';
    iframe.setAttribute('sandbox', 'allow-scripts allow-same-origin'); // Security enhancement

    this.container.appendChild(iframe);
    document.body.appendChild(this.container);

    // Add click handler to open reviews modal
    this.container.addEventListener('click', () => this.openReviewsModal());
  }

  getPositionStyles() {
    const margin = '20px';
    const positions = {
      'bottom-right': { bottom: margin, right: margin },
      'bottom-left': { bottom: margin, left: margin },
      'top-right': { top: margin, right: margin },
      'top-left': { top: margin, left: margin }
    };
    return positions[this.position] || positions['bottom-right'];
  }

  openReviewsModal() {
    if (document.querySelector('.star-rating-widget__modal')) return; // Prevent multiple modals

    const modal = document.createElement('div');
    modal.className = 'star-rating-widget__modal';
    modal.innerHTML = `
      <div class="star-rating-widget__modal-content">
        <button class="star-rating-widget__modal-close">&times;</button>
        <iframe 
          src="${this.apiUrl}/embed/reviews/${this.productId}?theme=${this.darkMode ? 'dark' : 'light'}"
          frameborder="0"
          style="width: 100%; height: 100%;"
          title="Product Reviews"
          sandbox="allow-scripts allow-same-origin"
        ></iframe>
      </div>
    `;

    document.body.appendChild(modal);

    // Close button handler
    modal.querySelector('.star-rating-widget__modal-close').addEventListener('click', () => {
      modal.remove();
    });

    // Close on outside click
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.remove();
      }
    });
  }
}

// Initialize the widget
const script = document.currentScript;
const productId = script.dataset.productId;
const position = script.dataset.position || 'bottom-right';

if (productId) {
  console.log('Found product ID:', productId);
  new StarRatingWidget(productId, position);
} else {
  console.error('No product ID provided');
}
