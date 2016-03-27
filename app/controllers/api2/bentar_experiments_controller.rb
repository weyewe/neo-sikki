class Api2::BentarExperimentsController < Api2::BaseReportApiController

  def calculate_the_shit
    # params 

    puts "The params is : #{params}"

    @rico_score = get_rico_score

  end

  def get_rico_score
    return 54542
  end


  def show_connection_path
    # source = params[:source]
    # target = params[:target]
    # jump = 1 
    puts "We are gonna fucking inspect the params from client\n"*10
    puts params 

    @paths  = get_connection_path
  end

  def get_connection_path

    return [
      {
        :node_type => "Education",
        :node_name => "IPB",
        :jump => 1 
      },
      {
        :node_type => "Education",
        :node_name => "Gunadarma",
        :jump => 2
      },
      {
        :node_type => "Page",
        :node_name => "S2 IPB rocks",
        :jump => 3
      }

    ]

  end
end



