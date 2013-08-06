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
    @regexp = /!roll (\d?)d(\d{1,2})/i

    # the response you want to write upon finding a match

    # user and password info for login
    @user = "timetorollthedie"
    @password = "iluvches"

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
    puts post_response = `curl -b reddit_session=#{@cookie} -d api_type=json -d text="#{text}" -d thing_id=t1_#{comment} -d uh=#{@modhash} https://ssl.reddit.com/api/comment`
  end

  def search
    while true do
      puts "start of loop"
      puts @pagination
      json = `curl -b reddit_session=#{@cookie} -d api_type=json -d uh=#{@modhash} https://ssl.reddit.com/comments.json?#{@pagination.empty? ? "limit=100" : @pagination}`
      next if json.empty?
      data = JSON.parse(json)

      @count += 100
      @pagination = "limit=100&count=#{@count}&after=#{data['data']['after']}"
      if data['data']['children'].empty?
        puts "results empty"
        @pagination = ''
        @count = 0
        next
      end
      data['data']['children'].each do |comment|
        if @visited[comment['data']['id']] != nil
          puts comment['data']['body']
          @pagination = ''
          @count = 0
          puts "comment already visited"
          break
        end
        if match = @regexp.match(comment['data']['body'])
          @matches << comment['data']['body']
          puts "attempting to post" 	
          response = roll(match.to_a)
          post(comment['data']['id'], response)
        end 
        @visited[comment['data']['id']] = true
      end
      puts "end of loop"
      puts "total visited: #{@visited.length}"
      puts @pagination
      sleep 1
    end
  end
  
  def roll(match_data)
    data = match_data.to_a
    data[1].empty? ? i = 1 : i = data[1].to_i
    dice = data[2].to_i
    results = []
    return_string = "You rolled: "
    i.times do
      return_string += (rand(dice) + 1).to_s + ' '
    end
    return_string
  end
end
