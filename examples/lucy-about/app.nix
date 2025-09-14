let
  component = import ../../src/core/component.nix;
  html = import ../../src/core/html.nix;
  css = import ../../src/core/css.nix;
  state = import ../../src/core/state.nix;

  # Pure Nix CSS for beautiful styling
  styles = {
    gradientBg = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; font-family: 'Inter', sans-serif;";
    card = "background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(20px); border-radius: 20px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); padding: 2rem; transform: translateY(0); transition: all 0.3s ease;";
    cardHover = "transform: translateY(-10px); box-shadow: 0 35px 60px -12px rgba(0, 0, 0, 0.3);";
    profileImage = "width: 120px; height: 120px; border-radius: 50%; background: linear-gradient(135deg, #ff6b6b, #4ecdc4); display: flex; align-items: center; justify-content: center; color: white; font-size: 3rem; font-weight: bold; margin: 0 auto 1rem;";
    skillTag = "display: inline-block; background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 0.5rem 1rem; border-radius: 25px; margin: 0.25rem; font-size: 0.875rem; font-weight: 500;";
    button = "background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 12px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);";
    buttonHover = "transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);";
    counter = "display: flex; align-items: center; gap: 1rem; justify-content: center; margin: 1rem 0;";
    counterValue = "font-size: 2rem; font-weight: bold; color: #333; min-width: 60px; text-align: center;";
  };

  # Enhanced profile card component
  profileCard = component.define "profile-card" {
    name = { type = "string"; required = true; };
    title = { type = "string"; required = true; };
    bio = { type = "string"; default = ""; };
    skills = { type = { type = "list"; itemType = "string"; }; default = []; };
  } (props: htmlLib: 
    htmlLib.div {
      attrs = { 
        style = styles.card;
        onmouseover = "this.style.cssText += '${styles.cardHover}'";
        onmouseout = "this.style.cssText = '${styles.card}'";
      };
      children = [
        (htmlLib.div {
          attrs = { style = "text-align: center; margin-bottom: 2rem;"; };
          children = [
            (htmlLib.div {
              attrs = { style = styles.profileImage; };
              children = [ (builtins.substring 0 1 props.name) ];
            })
            (htmlLib.h1 {
              attrs = { style = "font-size: 2.5rem; font-weight: bold; margin: 0 0 0.5rem 0; color: #333;"; };
              children = [ props.name ];
            })
            (htmlLib.p {
              attrs = { style = "font-size: 1.25rem; color: #666; margin: 0;"; };
              children = [ props.title ];
            })
          ];
        })
        (htmlLib.div {
          attrs = { style = "margin-bottom: 2rem;"; };
          children = [
            (htmlLib.p {
              attrs = { style = "color: #555; line-height: 1.6; font-size: 1.1rem;"; };
              children = [ props.bio ];
            })
          ];
        })
        (htmlLib.div {
          children = [
            (htmlLib.h3 {
              attrs = { style = "font-size: 1.5rem; font-weight: 600; margin: 0 0 1rem 0; color: #333;"; };
              children = [ "Skills" ];
            })
            (htmlLib.div {
              attrs = { style = "line-height: 1.8;"; };
              children = map (skill:
                htmlLib.span {
                  attrs = { style = styles.skillTag; };
                  children = [ skill ];
                }
              ) props.skills;
            })
          ];
        })
      ];
    });

  # Interactive counter component
  counter = component.define "counter" {
    value = { type = "int"; default = 0; };
    label = { type = "string"; default = "Counter"; };
  } (props: htmlLib:
    htmlLib.div {
      attrs = { style = "${styles.card} text-align: center;"; };
      children = [
        (htmlLib.h3 {
          attrs = { style = "font-size: 1.5rem; font-weight: 600; margin: 0 0 1rem 0; color: #333;"; };
          children = [ props.label ];
        })
        (htmlLib.div {
          attrs = { style = styles.counter; };
          children = [
            (htmlLib.button {
              attrs = { 
                style = styles.button;
                onmouseover = "this.style.cssText += '${styles.buttonHover}'";
                onmouseout = "this.style.cssText = '${styles.button}'";
                onclick = "updateCounter(-1)";
              };
              children = [ "−" ];
            })
            (htmlLib.span {
              attrs = { 
                style = styles.counterValue;
                id = "counter-value";
              };
              children = [ (builtins.toString props.value) ];
            })
            (htmlLib.button {
              attrs = { 
                style = styles.button;
                onmouseover = "this.style.cssText += '${styles.buttonHover}'";
                onmouseout = "this.style.cssText = '${styles.button}'";
                onclick = "updateCounter(1)";
              };
              children = [ "+" ];
            })
          ];
        })
      ];
    });

  # Feature showcase component
  featureShowcase = component.define "feature-showcase" {} (props: htmlLib:
    htmlLib.div {
      attrs = { style = styles.card; };
      children = [
        (htmlLib.h3 {
          attrs = { style = "font-size: 1.5rem; font-weight: 600; margin: 0 0 1rem 0; color: #333;"; };
          children = [ "NixUI Features" ];
        })
        (htmlLib.div {
          attrs = { style = "display: grid; gap: 0.75rem;"; };
          children = [
            (htmlLib.div {
              attrs = { style = "display: flex; align-items: center; color: #555; font-size: 1.1rem;"; };
              children = [ "✅ Enhanced Type System" ];
            })
            (htmlLib.div {
              attrs = { style = "display: flex; align-items: center; color: #555; font-size: 1.1rem;"; };
              children = [ "✅ Component Composition" ];
            })
            (htmlLib.div {
              attrs = { style = "display: flex; align-items: center; color: #555; font-size: 1.1rem;"; };
              children = [ "✅ Runtime State Management" ];
            })
            (htmlLib.div {
              attrs = { style = "display: flex; align-items: center; color: #555; font-size: 1.1rem;"; };
              children = [ "✅ Event Handling" ];
            })
            (htmlLib.div {
              attrs = { style = "display: flex; align-items: center; color: #555; font-size: 1.1rem;"; };
              children = [ "✅ Pure Nix Styling" ];
            })
          ];
        })
      ];
    });

  # Main app layout
  app = component.define "app" {} (props: htmlLib:
    htmlLib.div {
      attrs = { style = styles.gradientBg; };
      children = [
        (htmlLib.div {
          attrs = { style = "max-width: 1200px; margin: 0 auto; padding: 3rem 1rem;"; };
          children = [
            (htmlLib.h1 {
              attrs = { style = "font-size: 3rem; font-weight: bold; text-align: center; margin: 0 0 3rem 0; color: white; text-shadow: 0 4px 8px rgba(0,0,0,0.3);"; };
              children = [ "Lucy's NixUI Showcase" ];
            })
            (htmlLib.div {
              attrs = { style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 2rem; align-items: start;"; };
              children = [
                (profileCard.render {
                  name = "Lucy";
                  title = "AI Assistant & Code Enthusiast";
                  bio = "I help developers build amazing things with AI-powered assistance. From debugging complex code to architecting new systems, I'm here to make development faster and more enjoyable.";
                  skills = [
                    "JavaScript" "TypeScript" "Python" "Nix" 
                    "React" "Node.js" "Machine Learning" "System Design"
                    "Code Review" "Architecture" "Testing" "DevOps"
                  ];
                } html)
                (htmlLib.div {
                  attrs = { style = "display: grid; gap: 2rem;"; };
                  children = [
                    (counter.render {
                      value = 42;
                      label = "Interaction Counter";
                    } html)
                    (featureShowcase.render {} html)
                  ];
                })
              ];
            })
          ];
        })
        (htmlLib.script {
          children = [ ''
            let counterValue = 42;
            function updateCounter(delta) {
              counterValue += delta;
              document.getElementById('counter-value').textContent = counterValue;
            }
          '' ];
        })
      ];
    });

in {
  inherit app profileCard counter featureShowcase;
  
  # Render the complete HTML page
  html = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Lucy's NixUI Showcase</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; }
      </style>
    </head>
    <body>
      ${html.render (app.render {} html)}
    </body>
    </html>
  '';
}