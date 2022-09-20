@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest 
    private static void Product2Extension_UnitTest(){
        Test.startTest();

        Pagereference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        
            Product2 prod = new Product2(name='Test',isActive=true);
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(prod);

            Product2Extension ext = new Product2Extension(stdcontroller);
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());


            ext.addRows();
            System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());

            for (Integer i=0; i<5; i++){
                Product2Extension.ProductWrapper wrapper = ext.productsToInsert[i];
                Product2 p = new Product2();
                p.Name = 'Test Product' + i;
                p.IsActive = true;
                p.Initial_Inventory__c = 20;
                p.Family = Constants.PRODUCT_FAMILY[0].getValue();
                wrapper.productRecord = p;

                PricebookEntry pbe = new PricebookEntry();
                pbe.IsActive = true;
                pbe.UnitPrice = 10;
                wrapper.pricebookEntryRecord = pbe;
            }
            ext.save();
            ext.getFamilyOptions();
            ext.GetInventory();   
        Test.stopTest();

        List<Product2> addedProducts = [SELECT Id FROM Product2];
        System.assertEquals(5, addedProducts.size());
    }

    @isTest
    private static void Product2Trigger_UnitTest(){
        Test.startTest();
        Product2 p = new Product2();
        p.Name = 'TestProduct';
        p.Family = 'Entree';
        p.IsActive = true;
        p.Quantity_Ordered__c = 60;
        p.Initial_Inventory__c = 120;
        insert p;

        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'Test' + Constants.INVENTORY_ANNOUNCEMENTS;
        cg.description = 'test';
        cg.collaborationType = 'Public';
        insert cg;

        p.Quantity_Ordered__c = 116;
        update p;
        Test.stopTest();
    }
}