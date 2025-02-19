export CLIENT_ID=goapp
export CLIENT_SECRET=KGFO5LQnUxu1Zs.35gOem3MaG8odthg1U0v0.kScVPS6TPTWVRnAdT_nj4PYYSfuU6jdzTM6
export CLIENT_CALLBACK_URL=http://localhost:8080/oauth2/callback
export VERSION=0.0.1
export SESSION_KEY=aes1Itheich4aeQu9Ouz7ahcaiVoogh9
go run ./... \
  --id goapp \
  --issuer "https://sso.emile.space" \
  --secret "KGFO5LQnUxu1Zs.35gOem3MaG8odthg1U0v0.kScVPS6TPTWVRnAdT_nj4PYYSfuU6jdzTM6"
