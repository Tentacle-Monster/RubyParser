require 'nokogiri' 
require 'curb'
require 'csv'


def page_opn(addres)                                              #page open function
    begin
 http = Curl.get(addres) 
rescue
  puts "Ошибка открытия ресурса"
  exit
end
     html = Nokogiri::HTML(http.body_str)
    return html
end

def steal(addres)                                                #item parsing function
    full_item=[]
    mass = []
    price = []
    html = page_opn(addres)

    name = html.xpath('//h1').inner_html.strip!
    picture = html.xpath('//img[@id="bigpic"]').attr('src')
    mass+= html.xpath('//span[@class="radio_label"]').map{|sp| sp.inner_html}
    price+= html.xpath('//span[@class="price_comb"]').map{|sp| sp.inner_html.gsub(/[^0-9.]/, "").to_f}
    mass.each_with_index {|val, index|
        full_item << name + ' - ' + mass[index]
        full_item <<  price[index]
        full_item <<  picture

}
    return  full_item
end

start = Time.now                                                                        #programm time waste calculating starts

if ARGV.length == 2                                                                    #reading input parametres
filename = ARGV[0]
stealpath = ARGV[1]
else
    puts('некорректные аргументы!')
    exit
end


allitems = []
l = []
pg = 0
puts 'парсим ссылки на товар'



     threads = []
          threads << Thread.new { loop do
            local_pg =pg+=1 
            page_url = stealpath
            if pg>1 then page_url += "?p="<< local_pg.to_s end                                        #pagination check
             html = page_opn(page_url)
             l = html.css('div.pro_first_box a').map { |link| link['href'] }
            if  l.length==0 then break             
            end
            puts 'страница № ' << local_pg.to_s << ' прочитана'
            allitems+=l
            end
         } 
           threads << Thread.new { loop do
             local_pg =pg+=1 
            page_url = stealpath
            if pg>1 then page_url += "?p="<< local_pg.to_s end                                        #обход  пагинации
             html = page_opn(page_url)
             l = html.css('div.pro_first_box a').map { |link| link['href'] }
            if  l.length==0 then break             
            end
            puts 'страница № ' << local_pg.to_s << ' прочитана'
            allitems+=l
            end
         } 
           threads << Thread.new { loop do
             local_pg =pg+=1 
            page_url = stealpath
            if pg>1 then page_url += "?p="<< local_pg.to_s end                                       
             html = page_opn(page_url)
             l = html.css('div.pro_first_box a').map { |link| link['href'] }
            if  l.length==0 then break             
            end
            puts 'страница № ' << local_pg.to_s << ' прочитана'
            allitems+=l
            end
         } 
           threads << Thread.new { loop do
             local_pg =pg+=1 
            page_url = stealpath
            if pg>1 then page_url += "?p="<< local_pg.to_s end                                        
             html = page_opn(page_url)
             l = html.css('div.pro_first_box a').map { |link| link['href'] }
            if  l.length==0 then break             
            end
            puts 'страница № ' << local_pg.to_s << ' прочитана'
            allitems+=l
            end
         } 
         threads.each { |thr| thr.join }

pg -=4
    puts ' в разделе страниц ' << pg.to_s << ' и товаров '<< allitems.length.to_s          
    CSV.open( filename + ".csv", "w") do |csv|
     threads = []
        threads << Thread.new { while(allitems.length>0) do  result = steal(allitems.pop())
            while(result.length>0) do csv <<  result.pop(3) end end } 
           threads << Thread.new { while(allitems.length>0) do  result = steal(allitems.pop())
            while(result.length>0) do csv <<  result.pop(3) end end } 
                threads << Thread.new { while(allitems.length>0) do  result = steal(allitems.pop())
            while(result.length>0) do csv <<  result.pop(3) end end } 
                threads << Thread.new { while(allitems.length>0) do  result = steal(allitems.pop())
            while(result.length>0) do csv <<  result.pop(3) end end } 
                threads << Thread.new { while(allitems.length>0) do  result = steal(allitems.pop())
            while(result.length>0) do csv <<  result.pop(3) end end } 
                threads<<Thread.new{ while(allitems.length>0) do
                             puts ' осталось ' << allitems.length.to_s << ' необработанных товаров ' 
                             sleep(2) end}
        threads.each { |thr| thr.join }
end
   puts 'файл ' << filename + ".csv" << ' готов'
   timeend = Time.now
   time = timeend - start 
   timewaste = time 
   puts 'обработка заняла ' << timewaste.to_i.to_s << ' секунд'
   puts 'выход из программы'