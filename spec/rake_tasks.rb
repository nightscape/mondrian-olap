namespace :db do
  task :require_spec_helper do
    require File.expand_path("../spec_helper", __FILE__)
  end

  desc "Create test database tables"
  task :create_tables => :require_spec_helper do
    puts "==> Creating tables for test data"
    ActiveRecord::Schema.define do

      create_table :time, :force => true do |t|
        t.datetime    :the_date
        t.string      :the_day, :limit => 30
        t.string      :the_month, :limit => 30
        t.integer     :the_year
        t.integer     :day_of_month
        t.integer     :week_of_year
        t.integer     :month_of_year
        t.string      :quarter, :limit => 30
      end

      create_table :products, :force => true do |t|
        t.integer     :product_class_id
        t.string      :brand_name, :limit => 60
        t.string      :product_name, :limit => 60
      end

      create_table :product_classes, :force => true do |t|
        t.string      :product_subcategory, :limit => 30
        t.string      :product_category, :limit => 30
        t.string      :product_department, :limit => 30
        t.string      :product_family, :limit => 30
      end

      create_table :customers, :force => true do |t|
        t.string      :country, :limit => 30
        t.string      :state_province, :limit => 30
        t.string      :city, :limit => 30
        t.string      :fname, :limit => 30
        t.string      :lname, :limit => 30
        t.string      :fullname, :limit => 60
        t.string      :gender, :limit => 30
      end

      create_table :sales, :force => true, :id => false do |t|
        t.integer     :product_id
        t.integer     :time_id
        t.integer     :customer_id
        t.decimal     :store_sales, :precision => 10, :scale => 4
        t.decimal     :store_cost, :precision => 10, :scale => 4
        t.decimal     :unit_sales, :precision => 10, :scale => 4
      end
    end
  end

  task :define_models => :require_spec_helper do
    class TimeDimension < ActiveRecord::Base
      set_table_name "time"
      validates_presence_of :the_date
      before_create do
        self.the_day = the_date.strftime("%A")
        self.the_month = the_date.strftime("%B")
        self.the_year = the_date.strftime("%Y").to_i
        self.day_of_month = the_date.strftime("%d").to_i
        self.week_of_year = the_date.strftime("%W").to_i
        self.month_of_year = the_date.strftime("%m").to_i
        self.quarter = "Q#{(month_of_year-1)/3+1}"
      end
    end
    class Product < ActiveRecord::Base
      belongs_to :product_class
    end
    class ProductClass < ActiveRecord::Base
    end
    class Customer < ActiveRecord::Base
    end
    class Sales < ActiveRecord::Base
      set_table_name "sales"
      belongs_to :time_by_day
      belongs_to :product
      belongs_to :customer
    end
  end

  desc "Create test data"
  task :create_data => [:create_tables, :create_time_data, :create_product_data, :create_customer_data, :create_sales_data]

  task :create_time_data  => :define_models do
    puts "==> Creating time dimension"
    TimeDimension.delete_all
    start_time = Time.local(2010,1,1)
    (2*365).times do |i|
      TimeDimension.create!(:the_date => start_time + i.day)
    end
  end

  task :create_product_data => :define_models do
    puts "==> Creating product data"
    Product.delete_all
    ProductClass.delete_all
    families = ["Drink", "Food", "Non-Consumable"]
    (1..100).each do |i|
      product_class = ProductClass.create!(
        :product_family => families[i % 3],
        :product_department => "Department #{i}",
        :product_category => "Category #{i}",
        :product_subcategory => "Subcategory #{i}"
      )
      Product.create!(
        :product_class_id => product_class.id,
        :brand_name => "Brand #{i}",
        :product_name => "Product #{i}"
      )
    end
  end

  task :create_customer_data => :define_models do
    puts "==> Creating customer data"
    Customer.delete_all
    i = 0
    [
      ["Canada", "BC", "Burnaby"],["Canada", "BC", "Cliffside"],["Canada", "BC", "Haney"],["Canada", "BC", "Ladner"],
      ["Canada", "BC", "Langford"],["Canada", "BC", "Langley"],["Canada", "BC", "Metchosin"],["Canada", "BC", "N. Vancouver"],
      ["Canada", "BC", "Newton"],["Canada", "BC", "Oak Bay"],["Canada", "BC", "Port Hammond"],["Canada", "BC", "Richmond"],
      ["Canada", "BC", "Royal Oak"],["Canada", "BC", "Shawnee"],["Canada", "BC", "Sooke"],["Canada", "BC", "Vancouver"],
      ["Canada", "BC", "Victoria"],["Canada", "BC", "Westminster"],
      ["Mexico", "DF", "San Andres"],["Mexico", "DF", "Santa Anita"],["Mexico", "DF", "Santa Fe"],["Mexico", "DF", "Tixapan"],
      ["Mexico", "Guerrero", "Acapulco"],["Mexico", "Jalisco", "Guadalajara"],["Mexico", "Mexico", "Mexico City"],
      ["Mexico", "Oaxaca", "Tlaxiaco"],["Mexico", "Sinaloa", "La Cruz"],["Mexico", "Veracruz", "Orizaba"],
      ["Mexico", "Yucatan", "Merida"],["Mexico", "Zacatecas", "Camacho"],["Mexico", "Zacatecas", "Hidalgo"],
      ["USA", "CA", "Altadena"],["USA", "CA", "Arcadia"],["USA", "CA", "Bellflower"],["USA", "CA", "Berkeley"],
      ["USA", "CA", "Beverly Hills"],["USA", "CA", "Burbank"],["USA", "CA", "Burlingame"],["USA", "CA", "Chula Vista"],
      ["USA", "CA", "Colma"],["USA", "CA", "Concord"],["USA", "CA", "Coronado"],["USA", "CA", "Daly City"],
      ["USA", "CA", "Downey"],["USA", "CA", "El Cajon"],["USA", "CA", "Fremont"],["USA", "CA", "Glendale"],
      ["USA", "CA", "Grossmont"],["USA", "CA", "Imperial Beach"],["USA", "CA", "La Jolla"],["USA", "CA", "La Mesa"],
      ["USA", "CA", "Lakewood"],["USA", "CA", "Lemon Grove"],["USA", "CA", "Lincoln Acres"],["USA", "CA", "Long Beach"],
      ["USA", "CA", "Los Angeles"],["USA", "CA", "Mill Valley"],["USA", "CA", "National City"],["USA", "CA", "Newport Beach"],
      ["USA", "CA", "Novato"],["USA", "CA", "Oakland"],["USA", "CA", "Palo Alto"],["USA", "CA", "Pomona"],
      ["USA", "CA", "Redwood City"],["USA", "CA", "Richmond"],["USA", "CA", "San Carlos"],["USA", "CA", "San Diego"],
      ["USA", "CA", "San Francisco"],["USA", "CA", "San Gabriel"],["USA", "CA", "San Jose"],["USA", "CA", "Santa Cruz"],
      ["USA", "CA", "Santa Monica"],["USA", "CA", "Spring Valley"],["USA", "CA", "Torrance"],["USA", "CA", "West Covina"],
      ["USA", "CA", "Woodland Hills"],
      ["USA", "OR", "Albany"],["USA", "OR", "Beaverton"],["USA", "OR", "Corvallis"],["USA", "OR", "Lake Oswego"],
      ["USA", "OR", "Lebanon"],["USA", "OR", "Milwaukie"],["USA", "OR", "Oregon City"],["USA", "OR", "Portland"],
      ["USA", "OR", "Salem"],["USA", "OR", "W. Linn"],["USA", "OR", "Woodburn"],
      ["USA", "WA", "Anacortes"],["USA", "WA", "Ballard"],["USA", "WA", "Bellingham"],["USA", "WA", "Bremerton"],
      ["USA", "WA", "Burien"],["USA", "WA", "Edmonds"],["USA", "WA", "Everett"],["USA", "WA", "Issaquah"],
      ["USA", "WA", "Kirkland"],["USA", "WA", "Lynnwood"],["USA", "WA", "Marysville"],["USA", "WA", "Olympia"],
      ["USA", "WA", "Port Orchard"],["USA", "WA", "Puyallup"],["USA", "WA", "Redmond"],["USA", "WA", "Renton"],
      ["USA", "WA", "Seattle"],["USA", "WA", "Sedro Woolley"],["USA", "WA", "Spokane"],["USA", "WA", "Tacoma"],
      ["USA", "WA", "Walla Walla"],["USA", "WA", "Yakima"]
    ].each do |country, state, city|
      i += 1
      Customer.create!(
        :country => country,
        :state_province => state,
        :city => city,
        :fname => "First#{i}",
        :lname => "Last#{i}",
        :fullname => "First#{i} Last#{i}",
        :gender => i % 2 == 0 ? "M" : "F"
      )
    end
  end

  task :create_sales_data => :define_models do
    puts "==> Creating sales data"
    Sales.delete_all
    count = 100
    products = Product.order("id").limit(count).all
    times = TimeDimension.order("id").limit(count).all
    customers = Customer.order("id").limit(count).all
    count.times do |i|
      Sales.create!(
        :product_id => products[i].id,
        :time_id => times[i].id,
        :customer_id => customers[i].id,
        :store_sales => BigDecimal("2#{i}.12"),
        :store_cost => BigDecimal("1#{i}.1234"),
        :unit_sales => i+1
      )
    end
  end

end