module RegruHelper
  require 'domain'
  require 'reg_api2'
  require 'socket'
  
  RegApi2.username = 'Exod'
  RegApi2.password = '1qaz@WSX3edc'
  RegApi2.lang     = 'ru'

  def reg_domain_reg_ru(data)
    
  	reg_ru = RegApi2.domain.create(
      enduser_ip: local_ip,
			phone:"+7 777 2828967",
			birth_date:"11.10.1991",
			country:"KZ",
			descr:"Vschizh site",
			domain_name:data[:domain],
			e_mail:"hello@world.ru",
			ns0:"ns1.reg.ru",
			ns1:"ns2.reg.ru",
			output_content_type:"plain",
			p_addr:"12345 г.Вщиж ул.Княжеска Рюрику Святославу Владимировичу",
      passport:"22 44 668800 выдан по месту правления 01.01.1164",
			person:"Svyatoslav V Ryurik",
     	person_r:"Рюрик Святослав Владимирович",
		)
  end

  def set_records(data)
  	action_list = []
  	records_list = [{:action=>'add_mx',:type=>'MX',:server=>'ASPMX.L.GOOGLE.COM.', :priority=>'1'}, 
  			   {:action=>'add_mx',:type=>'MX',:server=>'ALT1.ASPMX.L.GOOGLE.COM.', :priority=>'5'},
  			   {:action=>'add_mx',:type=>'MX',:server=>'ALT2.ASPMX.L.GOOGLE.COM.', :priority=>'5'},
  			   {:action=>'add_mx',:type=>'MX',:server=>'ALT3.ASPMX.L.GOOGLE.COM.', :priority=>'10'},
  			   {:action=>'add_mx',:type=>'MX',:server=>'ALT4.ASPMX.L.GOOGLE.COM.', :priority=>'10'},
           {:action=>'add_txt',:type=>'TXT',:text=>data[:verify_txt], :subdomain=>'@'}
  	]
  	records_list.each do |record|
      if record[:type] == 'MX'
  	   action_list << { action: record[:action],
  	  				          record_type: record[:type],
  	  				          priority: record[:priority],
  	  				          content: record[:server]
  	  				        }
      elsif record[:type] == 'TXT'
        action_list << { action: record[:action],
                         text: record[:text],
                         subdomain: record[:subdomain]
                       }
      end

  	end
  	mx_answer = RegApi2.zone.update_records(
  	  domain_name: data[:domain], action_list: action_list
  	)
  end

  def renew_product_reg_ru(data)
    reg_ru = RegApi2.service.renew(
      domain_name: data[:domain],
      period: 1,
    )
  end

  def update_nss_reg_ru(data)
    reg_ru = RegApi2.domain.update_nss(
      dname: data[:domain],
      ns0: data[:ns0],
      ns0ip: data[:ns0ip],
      ns1: data[:ns1],
      ns1ip: data[:ns1ip],
    )
  end

  def ns_zone_clear(data)
    reg_ru = RegApi2.zone.clear(
        domain_name: data[:domain]
    )
  end

  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

end