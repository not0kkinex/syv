console.log('Hello from app.js');
function greet(name) {
  return `Hello, ${name}!`;
}
document.addEventListener('DOMContentLoaded', () => {
  const h1 = document.querySelector('h1');
  if (h1) h1.textContent = greet('World');
});
