# coding:utf-8
require 'time'
require 'date'

class Domoraen
	class Future
		AFTER_REGEXP = <<-'EOR'
		  	(?<after>(?<after_number>\d+)\s?(?<after_unit>秒|分|時間|日|週間)後)
		EOR
		DAY_IN_WEEK_REGEXP = <<-'EOR'
			(?<week>今週|再?来週)(?<day_in_week>月|火|水|木|金|土|日)曜日?
		EOR
		DATE_REGEXP = <<-'EOR'
			(?<date>
				(?<month>\d{1,2})\/(?<day>\d{1,2}) |
				(?<month>\d{1,2})\s?月\s?(?<day>\d{1,2})\s?日 |
				(?<date_japanese>明日|あす|あした|明後日|あさって|しあさって)
			)
		EOR
		TIME_REGEXP = <<-'EOR'
			(?<time>
				(?<hour>\d{1,2})\:(?<minute>\d{1,2}) |
				(?<hour>\d{1,2})\s?時\s?((?<minute>\d{1,2})\s?分)? |
				(?<time_japanese>未明|早朝|朝|お?昼|正午|おやつの時間|夕方|夜|深夜)
			)
		EOR
		# TODO: 今?週末
		REGEXP =  /
			(
				#{AFTER_REGEXP} |
				#{DAY_IN_WEEK_REGEXP}(の|\s)?#{TIME_REGEXP}? |
				#{DATE_REGEXP}\s?#{TIME_REGEXP}? |
				#{TIME_REGEXP}
			)\s?に?、?「(?<echo>.+)」
		/x
	
		class << self
			def parse(text)
				match = REGEXP.match(text)
				match ? parse_match(match) : nil
			end
			
			def parse_match(match)
				sec = nil
				if match[:after]
					case match[:after_unit]
					when '秒'   ; sec = match[:after_number].to_i
					when '分'   ; sec = match[:after_number].to_i * 60
					when '時間' ; sec = match[:after_number].to_i * 60 * 60
					when '日'   ; sec = match[:after_number].to_i * 60 * 60 * 24
					end
				else
					year, month, day, hour, minute = nil, nil, nil, nil, nil
					today = Date.today
					
					if match[:time]
						if match[:time_japanese]
							hour = case match [:time_japanese]
							when '未明'          ; 3
							when '早朝'          ; 6
							when '朝'            ; 9
							when /^(お?昼|正午)$/; 12
							when 'おやつの時間'  ; 15
							when '夕方'          ; 18
							when '夜'            ; 21
							when '深夜'          ; 0
							end 
							minute = 0
						else
							hour = match[:hour].to_i
							minute = match[:minute].to_i
						end
					else
						hour, minute = 0, 0
					end
			
					if match[:date]
						if match[:date_japanese]
							date =  case match[:date_japanese]
							when '今日', 'きょう', '本日' ; today + 1
							when '明日', 'あす', 'あした' ; today + 1
							when '明後日', 'あさって'     ; today + 2
							when 'しあさって'             ; today + 3
							end
							year, month, day = date.year, date.month, date.day
						elsif match[:month] && match[:day]
							year = today.year
							month, day = match[:month], match[:day]
							if Time.parse("#{year}/#{month}/#{day}") - Time.now <= 0
								year = year + 1
							end
						end
					elsif match[:week]
						days = {'月' => 1, '火' => 2, '水' => 3, '木' => 4, '金' => 5, '土' => 6, '日' => 7}
						date = today + (days[match[:day_in_week]] - today.wday)
						date = case match[:week]
						when '今週'  ; date
						when '来週'  ; date + 7
						when '再来週'; date + 14
						end
						year, month, day = date.year, date.month, date.day
					else
						date = today
						if Time.parse("#{hour}:#{minute}") - Time.now <= 0
							date += 1
						end
						year, month, day = date.year, date.month, date.day
					end
					puts "#{year}/#{month}/#{day} #{hour}:#{minute}"
					sec = (Time.parse("#{year}/#{month}/#{day} #{hour}:#{minute}") - Time.now).to_i
				end
				sec
			end
		end
	end
end
