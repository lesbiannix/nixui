// NixUI Client-Side Runtime for State Management and Event Handling
class NixUIRuntime {
  constructor(initialState = {}, updateFn = (state, _action) => state) {
    this.state = initialState;
    this.update = updateFn;
    this.subscriptions = new Set();
    this.eventHandlers = new Map();
    this.componentInstances = new Map();
  }

  // Subscribe to state changes
  subscribe(callback) {
    this.subscriptions.add(callback);
    return () => this.subscriptions.delete(callback);
  }

  // Dispatch an action to update state
  dispatch(action) {
    const newState = this.update(this.state, action);
    if (newState !== this.state) {
      this.state = newState;
      this.notifySubscribers();
    }
  }

  notifySubscribers() {
    this.subscriptions.forEach(callback => {
      try {
        callback(this.state);
      } catch (error) {
        console.error('Error in state subscription:', error);
      }
    });
  }

  // Register event handler for an element
  registerEventHandler(elementId, event, handler) {
    const key = `${elementId}:${event}`;
    this.eventHandlers.set(key, handler);
    
    // Attach DOM event listener
    const element = document.getElementById(elementId);
    if (element) {
      element.addEventListener(event, (e) => {
        const registeredHandler = this.eventHandlers.get(key);
        if (registeredHandler) {
          registeredHandler(e, this.dispatch.bind(this));
        }
      });
    }
  }

  // Initialize runtime with pre-rendered HTML
  hydrate(containerSelector = 'body') {
    const container = document.querySelector(containerSelector);
    if (!container) {
      throw new Error(`Container ${containerSelector} not found`);
    }

    // Find all elements with data-nixui-* attributes for event handling
    const interactiveElements = container.querySelectorAll('[data-nixui-id]');
    interactiveElements.forEach(element => {
      const nixuiId = element.getAttribute('data-nixui-id');
      const events = element.getAttribute('data-nixui-events');
      
      if (events) {
        const eventList = events.split(',');
        eventList.forEach(event => {
          const handler = this.getEventHandler(nixuiId, event);
          if (handler) {
            element.addEventListener(event, handler);
          }
        });
      }
    });

    // Initial render
    this.render(container);
  }

  // Get event handler for component
  getEventHandler(componentId, eventType) {
    return (event) => {
      // Extract component info
      const compName = componentId.split('-')[0];
      const action = {
        type: `${compName}_${eventType}`,
        componentId,
        event: {
          type: event.type,
          target: event.target.tagName,
          value: event.target.value || null
        }
      };
      this.dispatch(action);
    };
  }

  // Re-render components based on state
  render(container) {
    // This would integrate with the Nix compiler output
    // For now, just update elements that have state bindings
    const stateElements = container.querySelectorAll('[data-nixui-state]');
    stateElements.forEach(element => {
      const statePath = element.getAttribute('data-nixui-state');
      const value = this.getStateValue(statePath);
      
      if (element.tagName === 'INPUT') {
        element.value = value || '';
      } else {
        element.textContent = value || '';
      }
    });
  }

  // Get nested state value by path (e.g., "todos.0.text")
  getStateValue(path) {
    return path.split('.').reduce((obj, key) => obj?.[key], this.state);
  }

  // Helper to create actions
  createAction(type, payload = {}) {
    return { type, ...payload, timestamp: Date.now() };
  }
}

// Export for use in browsers and Node.js
if (typeof window !== 'undefined') {
  window.NixUIRuntime = NixUIRuntime;
} else if (typeof module !== 'undefined' && module.exports) {
  module.exports = NixUIRuntime;
}