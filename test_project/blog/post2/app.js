console.log('Blog post 2 script');
function loadComments() {
  return fetch('/api/comments').then(r => r.json());
}
