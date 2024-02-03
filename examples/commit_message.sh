git add .
git commit -m "$(git diff --cached | chatgpt -m 'Please create a simple commit message')"
