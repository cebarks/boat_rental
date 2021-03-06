require 'minitest/autorun'
require 'minitest/pride'

require './lib/dock'
require './lib/boat'
require './lib/renter'

class DockTest < Minitest::Test
  def setup
    @dock = Dock.new("The Rowing Dock", 3)
    @kayak_1 = Boat.new(:kayak, 20)
    @kayak_2 = Boat.new(:kayak, 20)
    @canoe = Boat.new(:canoe, 25)
    @sup_1 = Boat.new(:standup_paddle_board, 15)
    @sup_2 = Boat.new(:standup_paddle_board, 15)
    @patrick = Renter.new("Patrick Star", "4242424242424242")
    @eugene = Renter.new("Eugene Crabs", "1313131313131313")
  end

  def helper_patrick
    @dock.rent(@kayak_1, @patrick)
    @dock.rent(@kayak_2, @patrick)
    @dock.log_hour
    @dock.rent(@canoe, @patrick)
    @dock.log_hour
    @dock.return(@kayak_1)
    @dock.return(@kayak_2)
    @dock.return(@canoe)
  end

  def helper_eugene
    @dock.rent(@sup_1, @eugene)
    @dock.rent(@sup_2, @eugene)
    5.times do
      @dock.log_hour
    end
    @dock.return(@sup_1)
    @dock.return(@sup_2)
  end

  def test_it_exists
    assert_instance_of Dock, @dock
  end

  def test_it_has_a_name
    assert_equal "The Rowing Dock", @dock.name
  end

  def test_it_has_a_max_rental_time
    assert_equal 3, @dock.max_rental_time
  end

  def test_it_can_rent_a_boat
    @dock.rent(@kayak_1, @patrick)
    assert_equal [@kayak_1], @dock.currently_rented_boats
  end

  def test_it_can_rent_multiple_boats_at_once
    @dock.rent(@kayak_1, @patrick)
    @dock.rent(@kayak_2, @patrick)
    assert_equal [@kayak_1, @kayak_2], @dock.currently_rented_boats
  end

  def test_it_can_rent_multiple_boats_to_different_people
    @dock.rent(@kayak_1, @patrick)
    @dock.rent(@kayak_2, @eugene)
    assert_equal [@kayak_1, @kayak_2], @dock.currently_rented_boats
  end

  def test_it_can_log_hours_on_boats
    @dock.rent(@kayak_1, @patrick)
    @dock.log_hour
    assert_equal 1, @kayak_1.hours_rented
  end

  def test_it_can_return_a_boat
    assert_equal [], @dock.currently_rented_boats
    @dock.rent(@kayak_1, @patrick)
    @dock.return(@kayak_1)
    assert_equal [], @dock.currently_rented_boats
  end

  def test_it_can_calculate_revenue
    helper_patrick
    assert_equal 105, @dock.revenue
  end

  def test_it_wont_add_hours_past_max_rental_time
    @dock.rent(@kayak_1, @patrick)
    4.times do
      @dock.log_hour
    end
    assert_equal 3, @kayak_1.hours_rented
  end

  def test_it_stores_charges_per_renter
    helper_patrick
    helper_eugene
    expected = {"4242424242424242" => 105, "1313131313131313" => 90}
    assert_equal expected, @dock.charges
  end

  def test_it_hols_total_hours_per_rental_type
    helper_patrick
    helper_eugene
    expected = {:kayak => 4, :canoe => 1, :standup_paddle_board => 10}
    assert_equal expected, @dock.total_hours_by_rental_type
  end
end
