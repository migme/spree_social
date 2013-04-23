module Spree
  module SocialHelper
    def post_to_fb_feed(url, options= {})
      fb_img = s3_url('spree_social/facebook_32.png')
      link_to(image_tag(fb_img), '#', :onclick => "postToFeed('#{url}',{picture: '#{options[:picture]}'})")
    end

    def share_friend(url, message)
      fb_img = s3_url('spree_social/facebook_32.png')
      link_to(image_tag(fb_img), '#', :onclick => "sendToFBFriends('#{url}','#{message}')")
    end

    def twitter_share(url)

    end
  end
end