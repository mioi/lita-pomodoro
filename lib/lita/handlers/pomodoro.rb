require 'time'

module Lita
  module Handlers
    class Pomodoro < Handler
      route(/^(\d+)$/, :start, command: true, help: {"25" => "Start a pomodoro session of 25 minutes in length."})
      route(/^until\s+(.+)$/, :start, command:true, help: {"until TIME" => "Start a pomodoro session lasting until TIME (ex: until 5:00pm)."})
      route(/^stop$/, :stop, command: true, help: {"stop" => "Stop a pomodoro session."})
      route(/^list$/, :list, command: true, help: {"list" => "List everyone who's pomodoroing right now."})
      route(/^@(\w+)/, :auto_respond, command: false)

      def start(response)
        user = response.user
        now = Time.now
        match = response.matches.join('').strip
        if match.match(/^\d+$/)
          min = match.to_i
        else
          stop_time = Time.parse(match)
          min = ((stop_time - now)/60).to_i
        end
        active = false
        if user.metadata["pomodoro_stop"] && Time.parse(user.metadata["pomodoro_stop"]) > now
          reply_message = "Restarting existing pomodoro session for #{min} minutes"
        else
          reply_message = "Starting pomodoro session for #{min} minutes"
        end
        stop_time ||= now + min*60
        response.reply("@#{user.mention_name}: #{reply_message} (until #{stop_time.strftime("%l:%M%P")}).")
        # set stop time by modifying metadata on user info
        Lita::User.create(user.id, metadata = {:pomodoro_stop => stop_time})
        # notify them when their pomodoro is up
        after(min*60) { |timer|
          response.reply_privately("#{user.name}, your pomodoro session has ended!")
          log.debug("#{user.mention_name}'s pomodoro session ended")
        }
        log.debug("#{user.mention_name} started a pomodoro session")
      end

      def stop(response)
        user = response.user
        now = Time.now
        if user.metadata["pomodoro_stop"] && Time.parse(user.metadata["pomodoro_stop"]) > now
          reply_message = "Stopping your pomodoro session."
          # set stop time by modifying metadata on user info
          Lita::User.create(user.id, metadata = {:pomodoro_stop => now})
        else
          reply_message = "You weren't pomodoroing."
        end
        response.reply_privately("@#{user.mention_name}: #{reply_message}")
        log.debug("#{user.mention_name} ended a pomodoro session")
      end

      def list(response)
        users = Lita::User.find_by_pomodoro
        if users.empty?
          response.reply("No pomodoros currently!")
        else
          response.reply("Currently pomodoroing:\n#{users.map{|u| "#{u.name} (until #{Time.parse(u.metadata["pomodoro_stop"]).strftime("%l:%M%P")})" }.join("\n")}")
        end
      end

      def auto_respond(response)
        match = response.matches.join('').strip
        # check if match is pomodoroing
        if found_user = Lita::User.find_by_pomodoro.find {|u| u.mention_name == match }
          response.reply("@#{response.user.mention_name} #{found_user.mention_name} is currently pomodoroing, until #{Time.parse(found_user.metadata["pomodoro_stop"]).strftime("%l:%M%P")}.")
        end
      end

      Lita.register_handler(self)
    end
  end

  class User
    class << self
      def all_users
        keys = redis.keys("name:*")
        keys.map {|k| find_by_id(redis.get(k)) }
      end

      def find_by_pomodoro
        all_users.select {|u| u.metadata["pomodoro_stop"] && Time.parse(u.metadata["pomodoro_stop"]) > Time.now }.uniq {|u| u.id }
      end
    end
  end
end
