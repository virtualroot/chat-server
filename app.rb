require "json"
require "syro"
require "rack/contrib"
require "ohm"
require "shield"
require "basica"

include Basica

Ohm.redis = Redic.new("redis://127.0.0.1:6379")

class User < Ohm::Model
  include Shield::Model

  attribute :username
  attribute :crypted_password

  unique :username
  index :username

  def self.fetch(identifier)
    with(:username, identifier)
  end

  collection :messages, :Message
end

class Message < Ohm::Model
  attribute :body
  attribute :from

  reference :user, :User
end

class WebDeck < Syro::Deck

  def auth(m)
    on env["HTTP_AUTHORIZATION"].nil? do
      res.status = 401
      res.headers["WWW-Authenticate"] = 'Basic realm="MyApp"'
      res.write "Unauthorized"
    end

    basic_auth(env) do |username, password|
      user = m.fetch(username)

      if user and m.is_valid_password?(user, password)
        return true
      else
        res.status = 403
        res.write "wrong credentisl"
      end
    end
  end

  def json(template)
    res.headers["Content-Type"] ||=  "application/json; charset=utf-8"
    res.write template.to_json
  end

  def whoami()
    auth = env["HTTP_AUTHORIZATION"].split(" ")[1]
    username = Base64.decode64(auth).split(":")[0]
    user = User.fetch(username)
    return user
  end

end

Web = Syro.new(WebDeck) do

  on("register") {
    post {
      User.create(username: req.POST["username"],
        password: req.POST["password"])

      res.status = 201
    }
  }

  on(auth(User)) {
    on("users") {
      get {
        json(User.all.sort(by: :id, get: :username))
      }
      on("count") {
        get {
          json(User.all.count)
        }
      }
  
      on("messages") {
        get {
          h = Hash[whoami.messages.map { |x| [x.id, [x.from, x.body]] }]
          json(h)
        }
        post {
          m = Message.create(body: req.POST["body"], from: whoami.id, user: whoami)
          json(m.body)
        }
        on(:id) {
          m = whoami.messages[inbox[:id]]
        
          get {
            json(m)
          }

        }
      }
    }
  }
end
