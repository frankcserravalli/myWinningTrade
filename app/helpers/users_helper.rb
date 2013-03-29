module UsersHelper
  def scramble_token(time, string)
    time = time.to_s.split("")
    string_array = string.split("")
    index = 0
    time.map do |time_character|
      string_array.insert(index, time_character)
      index += 2
    end
    string_array.join("")
  end

  def unscramble_token(string)
    string_array = string.split("")
    index = 1
    string_array.each do
      string_array.delete_at(index)
      index += 1
    end
    string = Time.parse(string_array.join(""))
  end

  def create_random_string
    string = ('a'..'z').to_a + (1..9).to_a
    string = string.shuffle[0,25].join
  end

  def require_iphone_login
    # Runs all iphone controllers
    if params[:controller].match(/v1/)
      # TODO Yes, there is an easier way to do this. I'll work on it later.
      if params.has_key? :ios_token
        eight_hours_ago = Time.now - 8.hours
        auth_token_time = unscramble_token(params[:ios_token])
        if auth_token_time < eight_hours_ago
          render :json => {}
        end
      else
        render :json => {}
      end
    end
  end
end

