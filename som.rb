# coding: utf-8
require "pp"
require "pry"

class Som
  UnitX = 30
  UnitY = 30
  SigmaE = 0.7
  SigmaO = UnitX
  Tau1 = 150
  InputFile = "input_animal.data"
  #InputFile = "color.data"

  def initialize
    read_file
    set_weight
  end

  def learning(num)
    puts "learning start"

    @tau_2 = num

    num.times do |n|
      t = rand(@data_n)
      data_t = @data[t]

      @distance = []

      euclidean_distance(t, data_t)
      k_unit_x, k_unit_y = minimum_distance_unit
      proximity_function(k_unit_x, k_unit_y, num, n, data_t)

      print "#{n}/#{num} \r" if n % 100 == 0

    end
    # p @weight
  end

  def result
    result_winner_unit
    result_bond_distance
    result_color
    to_html

    puts "Finish"
  end

  def to_html
    html = "<html><head></head><body>"
    html += "<table border='0'></tbody>"

    UnitX.times do |x|
      html += "<tr>"
      UnitY.times do |y|
        rgb = "%02x%02x%02x"%[@color[x][y][:r], @color[x][y][:g], @color[x][y][:b]]
        html += "<td width='50' bgcolor='##{rgb}' style='text-shadow: 0px 0px 2px #ffffff; '>#{@out[x][y]}.</td>"
      end
      html += "</tr>"
    end

    html += "</tbody></table>"
    html += "</body></html>"

    File.binwrite("out.html", html)
  end

  def result_color
    @color = []
    UnitX.times do |x|
      @color[x] = []
      UnitY.times do |y|
        @color[x][y] = {}
        c_temp = ((@out_distance[x][y] - @out_dist_min) * (200*4 / (@out_dist_max - @out_dist_min))).to_i

        if c_temp <= 200
          # 赤->黄
          @color[x][y][:r] = 200 + 55
          @color[x][y][:g] = c_temp + 55
          @color[x][y][:b] = 55
        elsif c_temp <= 200*2
          # 黄->緑
          @color[x][y][:r] = 200 - (c_temp - 200) + 55
          @color[x][y][:g] = 200 + 55
          @color[x][y][:b] = 55
        elsif c_temp <= 200*3
          # 緑->水色
          @color[x][y][:r] = 55
          @color[x][y][:g] = 200 + 55
          @color[x][y][:b] = 55 + (c_temp - 200*2)
        else
          # 黄->赤
          @color[x][y][:r] = 55
          @color[x][y][:g] = 200 - (c_temp - 200*3 + 55)
          @color[x][y][:b] = 200 + 55
        end
      end
    end
  end

  def result_bond_distance
    @out_distance = []
    UnitX.times {|x| @out_distance[x] = []}

    UnitX.times do |x|
      UnitY.times do |y|
        denominator = 0
        bond_distance = 0

        (-1..1).each do |l|
          (-1..1).each do |k|
            if (l + x >= 0 && l + x < UnitX && k + y >= 0 && k + y < UnitX && !(k == 0 && l == 0))
              denominator += 1
              distance_temp = 0

              @data_v.times do |v|
                distance_temp += (@weight[x][y][v] - @weight[x + l][y + k][v])**2
              end
              bond_distance = distance_temp**(1/2.0)
            end
          end
        end
        temp = bond_distance / denominator
        @out_distance[x][y] = temp

        if (x == 0 && y == 0)
          @out_dist_max = temp
          @out_dist_min = temp

          puts "初期max: #{@out_dist_max}"
          puts "初期min: #{@out_dist_min}"
        end

        if temp > @out_dist_max
          @out_dist_max = temp
        end
        if temp < @out_dist_min
          @out_dist_min = temp
        end
      end
    end

    puts "最高max: #{@out_dist_max}"
    puts "最高min: #{@out_dist_min}"
  end

  def result_winner_unit
    @out = []
    UnitX.times do |x|
      @out[x] = []
    end

    @data_n.times do |dn|
      # ユークリッド距離
      UnitX.times do |x|
        UnitY.times do |y|
          temp_dist = 0

          @data_v.times do |v|
            temp_dist += (@data[dn][v] - @weight[x][y][v])**2
          end
          @distance[x][y] = temp_dist**(1/2.0)
        end
      end

      # 最小距離とそれを持つユニット
      mins = []
      king_unit_y_t = []
      UnitX.times do |x|
        mins[x] = @distance[x].min
        king_unit_y_t[x] = @distance[x].index(mins[x])
      end
      min = mins.min

      king_unit_x = mins.index(min)
      king_unit_y = king_unit_y_t[king_unit_x]

      @out[king_unit_x][king_unit_y] = @meta_data[:tags][dn]
      puts "#{dn} #{@meta_data[:tags][dn]}  勝者ユニット: (#{king_unit_x})(#{king_unit_y})"
    end
  end

  private

  # ユークリッド距離算出
  def euclidean_distance(t, data_t)
    UnitX.times do |x|
      @distance[x] = []
      UnitY.times do |y|
        temp_dist = 0
        @data_v.times do |v|
          temp_dist += (data_t[v] - @weight[x][y][v])**2
        end
        @distance[x][y] = temp_dist**(1/2.0)
      end
    end

    # pp @distance
  end

  # 勝者ユニット算出
  def minimum_distance_unit
    mins = []
    king_unit_y_t = []
    UnitX.times do |x|
      mins[x] = @distance[x].min
      king_unit_y_t[x] = @distance[x].index(mins[x])
    end
    min = mins.min

    king_unit_x = mins.index(min)
    king_unit_y = king_unit_y_t[king_unit_x]

    [king_unit_x, king_unit_y]
  end

  # 近傍関数
  def proximity_function(king_unit_x, king_unit_y, num, n, data_t)
    sigma = SigmaE + (SigmaO - SigmaE)*Math.exp(-num/Tau1)
    eta = 1 - (n/num)
    UnitX.times do |x|
      UnitY.times do |y|
        proximity_distance = (king_unit_x - x)**2 + (king_unit_y - y)**2
        phin = Math.exp(-(proximity_distance/(2*(sigma**2))))

        @data_v.times do |v|
          @weight[x][y][v] += eta * phin * (data_t[v] - @weight[x][y][v])
        end
      end
    end
  end

  def set_weight
    @weight = []
    UnitX.times do |x|
      @weight[x] = []
      UnitY.times do |y|
        @weight[x][y] = []
        @data_v.times do |d|
          @weight[x][y][d] = rand
        end
      end
    end
  end

  def read_file
    @meta_data = {}
    @data = []

    i = 0
    IO.foreach(InputFile) do |s|
      if i == 0
        _, @meta_data[:n], @meta_data[:v] = s.split(",").map(&:chomp).map(&:to_i)
      elsif i == 1
        @meta_data[:tags] = s.split(",").map(&:chomp)
        @meta_data[:tags].shift
      else
        @data << s.split(",").map(&:chomp).map(&:to_i)
      end

      i += 1
    end

    @data_v = @data.first.size
    @data_n = @data.size

    puts "データベクトル#{@data_v}"
    puts "データの数#{@data_n}"
    p @meta_data[:tags]
    p @data
  end
end

num = ARGV[0].to_i || 5000

target = Som.new
target.learning(num)
target.result
