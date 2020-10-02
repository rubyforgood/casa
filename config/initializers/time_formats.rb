# frozen_string_literal: true

Time::DATE_FORMATS[:date_only] = lambda { |time| time.strftime("%A, %B the #{time.day.ordinalize}") }
