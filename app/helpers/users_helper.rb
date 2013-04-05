require 'securerandom'

module UsersHelper
  def scramble_token(time, user_id)
    user_id = user_id.to_s

    user_id_length = user_id.length

    length_of_random_string = 32 - user_id_length

    random_string = SecureRandom.hex(length_of_random_string).to_s

    position = 0

    index = 0

    # Here we inject the user_id into the random_string produced by SecureRandom
    user_id_length.times do
      # Here we insert the user_id character into the random string
      random_string.insert(index, user_id[position])

      # Increasing the position where user_id is inserted into the secure random string
      index += 2

      # Let us use the next character in the user_id
      position += 1
    end

    # Split up the time into an array of each character
    time = time.to_s.split("")

    # Split up the create random string into an array of each character
    random_string = random_string.to_s.split("")

    # Reset index to zero
    index = 0

    # Here we loop through the time array, and insert the time into the string array
    time.map do |character|
      random_string.insert(index, character)

      index += 2
    end

    # Turn array back into string
    random_string = random_string.join("")

    scrambled_token = user_id_length.to_s + random_string
  end

  def unscramble_token(string, extra_protection = false)

    # Declaring variables below
    scrambled_token = string.split("")

    user_id = ""

    # Grab the user id length and delete it from the scrambled token
    user_id_length = scrambled_token.shift

    index = 1

    random_string_in_arry = []

    # Here we begin looping through and grabbing the random string
    scrambled_token.each do
      # Begin building up random string from scrambled token
      random_string_in_arry << scrambled_token[index]

      # Delete the random string character
      scrambled_token.delete_at(index)

      index += 1
    end

    ## Now we extract the user_id from the random string
    user_id_length.to_i.times do
      user_id << random_string_in_arry.first
      random_string_in_arry.shift(2)
    end

    # Have the time converted appropriately back into an instance of Time
    time = Time.parse(scrambled_token.join(""))

    # Here we return the info based on level of security we want to return
    if extra_protection.eql? false
      returned_info = time
    else
      returned_info = [time, user_id]
    end
  end

  def require_iphone_login
    # Runs all iphone controllers
    if params[:controller].match(/v1/)
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

