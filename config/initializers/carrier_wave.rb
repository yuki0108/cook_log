if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Amazon S3用の設定
      :provider              => 'AWS',
      :region                => ENV['ap-northeast-1'],
      :aws_access_key_id     => ENV['AKIASS2H7XBRMIMYVTP4'],
      :aws_secret_access_key => ENV['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']
    }
    config.fog_directory     =  ENV['cooklogapp']
  end
end