Finance.credentials = YAML::load_file(Rails.root.join('config', 'finance.yml'))[Rails.env.to_s]
raise "No finance API credentials specified for environment #{Rails.env}" unless Finance.credentials
