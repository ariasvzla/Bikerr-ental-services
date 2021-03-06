# the concrete component we would like to decorate, a bike
class BasicBike
   def initialize(price, quantity, category)
        @price = price
        @quantity = quantity
        @category = category
        @addons = 'Addon for'

    end
    
    # getter method
    def cost 
        return @price
    end
     def quantity
        return @quantity
    end
      def details
        return  @addons + ": " + @category + " Bike"
    end
    # a method which returns a string representation of the object of type BasicBike

    
    # getter method
    def category 
        return @category
    end

    
end # ends the BasicCar class



# decorator class -- this serves as the superclass for all the concrete decorators
# the base/super class decorator (i.e. no actual decoration yet), each concrete decorator (i.e. subclass) will add its own decoration
class BikeDecorator < BasicBike
    def initialize(basic_bike)
        #basic_bike is a real bike, i.e. the component we want to decorate
        @basic_bike = basic_bike
        super(@basic_bike.cost, @basic_bike.quantity, @basic_bike.category)
        @extra_cost = 0
        @addons= "no extra addons"
    end
    
    # override the cost method to include the cost of the extra feature	
    def cost        
        return @extra_cost + @basic_bike.cost
    end
    
    # override the details method to include the description of the extra feature
    def details
        return  @addons + "   " +@basic_bike.details
    end
    
end # ends the BikeDecorator class


# a concrete decorator --  define an extra feature
class HelmetDecorator < BikeDecorator
    def initialize(basic_bike)
        super(basic_bike)
        @extra_cost = 0
         @addons = "Helmet"
    end
    
end # ends the HelmetDecorator class


# another concrete decorator -- define an extra feature
class LigthsDecorator < BikeDecorator
    def initialize(basic_bike)
        super(basic_bike)
        @extra_cost = 5
        @addons = "Ligths"
    end
    
end # ends the LightsDecorator class


# another concrete decorator -- define an extra feature
class BasketDecorator < BikeDecorator
    def initialize(basic_bike)
        super(basic_bike)
        @extra_cost = 10
         @addons = "Basket"
    end
    
end # ends the BasketDecorator class

