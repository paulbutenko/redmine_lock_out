class LockOutController < ApplicationController
  unloadable
  before_action :authorize_global
  before_action :find_or_create_date, :only => [:lock, :unlock]

  def index
    now = Time.now + 1.month
    @dates = []

    # generate last 7 months + current month
    8.times do |i|
      now = now - 1.month
	  if (now.month == Time.now.month)
		current = LockOutDate.
        where(:month => now.month).
        where(:year  => now.year).
        first
		if current.nil?
			current =  LockOutDate.
	        where(:month => now.month).
	        where(:year  => now.year).
			where(:locked  => false).
			create
		end
		@dates << current
      else
		@dates << LockOutDate.
        where(:month => now.month).
        where(:year  => now.year).
        first_or_create
      end
    end

    @dates.sort! { |x,y| y <=> x }
    @dates
  end

  def lock
    @date.locked = true
    if @date.save
      redirect_to lock_out_path, :notice => "Dates were locked successfully."
    else
      redirect_to lock_out_path, :error => "The dates could not be locked."
    end
  end

  def unlock
    @date.locked = false
    if @date.save
      redirect_to lock_out_path, :notice => "Dates were unlocked successfully."
    else
      redirect_to lock_out_path, :error => "The dates could not be unlocked."
    end
  end

  private

  def find_or_create_date
    @date = LockOutDate.
      where(:month => params[:month], :year => params[:year]).
      first_or_create!
  end

end
