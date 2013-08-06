require 'json'

class Responder
  attr_accessor :modhash, :cookie
  
  def initialize
  
    @visited = {}

    # string to add at the end of the curl for pagination
    @pagination = ''

    # tracks current page.  count / 25 == current page from start of loop
    @count = 0

    # stores any comments that have been matched
    @matches = []

    # insert a regexp to match whatever you are looking for in a comment
    @regexp = 

    # the response you want to write upon finding a match
    @response = 

    # user and password info for login
    @user = 
    @password =

    #the modhash is received from the reddit server upon login and is used to
    #identify the user when making comments/posts etc
    modhash = ''
  end
  
  def login
    json = `curl -duser=#{@user} -dpasswd=#{@password} -dapi_type=json https://ssl.reddit.com/api/login`
    data = JSON.parse(json)
    @modhash = data['json']['data']['modhash']
    @cookie = data['json']['data']['cookie']
    data
  end

  def post(comment, text)
    post_response = `curl -b reddit_session=#{@cookie} -dapi_type=json -dtext="#{text}" -dthing_id=#{comment} -duh=#{@modhash} https://ssl.reddit.com/api/comment`
    puts JSON.parse(post_response)
  end

  def post(comment, text)
    puts post_response = `curl -b reddit_session=#{@cookie} -d api_type=json -d text="#{text}" -d thing_id=t1_#{comment} -d uh=#{@modhash} https://ssl.reddit.com/api/comment`
  end

  def search
    while true do
      json = `curl http://www.reddit.com/comments.json#{@pagination}`
      next if json.empty?
      data = JSON.parse(json)
      @count += 25
      @pagination = "?count=#{@count}&after=#{data['data']['after']}"
      if data['data']['children'].empty?
        puts "results empty"
        @pagination = ''
        @count = 0
        next
      end
      data['data']['children'].each do |comment|
        if @visited[comment['data']['id']] != nil
          @pagination = ''
          @count = 0
          sleep 60
          break
        end
        if @regexp.match(comment['data']['body'])
          @matches << comment['data']['body']
          puts "attempting to post" 	
          post(comment['data']['id'], @response)
        end 
        @visited[comment['data']['id']] = true
      end

    puts @visited.length
    puts @matches.length
    puts @pagination.inspect
    sleep 1
    end
  end
end
