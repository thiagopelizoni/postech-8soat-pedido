db.auth('api', 'E4dfapgwDeJbFhH2zB')
db = db.getSiblingDB('development')

db.createUser({
  user: 'api',
  pwd: 'E4dfapgwDeJbFhH2zB',
  roles: [
    { role: 'readWrite', db: 'development' },
    { role: 'readWrite', db: 'test' },
    { role: 'readWrite', db: 'production' }
  ]
})