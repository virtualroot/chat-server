# chat-server

### Register a new user
`curl 'http://localhost:9393/register' -H 'Content-Type: application/json; charset=UTF-8' -H 'Accept: application/json' --data-binary '{"username":"foo","password":"bar"}'`

### List users
Endpoint requires valid user/pass.

`curl 'http://foo:bar@localhost:9393/users/`

### Send message
Endpoint requires valid user/pass.

`curl 'http://foo:bar@localhost:9393/users/messages' --data-binary '{"to":"abc","body":"zzz"}'`

### List message
Endpoint requires valid user/pass.

`curl 'http://foo:bar@localhost:9393/users/messages'`

### Read message [ID]
Endpoint requires valid user/pass.

`curl 'http://foo:bar@localhost:9393/users/messages/[ID]'`
