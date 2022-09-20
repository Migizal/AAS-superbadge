public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(Apexpages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public List<SelectOption> getFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for(PicklistEntry indvPickValue : Constants.PRODUCT_FAMILY){
        options.add(new SelectOption(indvPickValue.getValue(), indvPIckValue.getLabel()));

        }
        return options;
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();

        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pbEntrys = new List<PricebookEntry>();
        for(ProductWrapper pwrapper : productsToInsert){
            if(pwrapper.productRecord != null && pwrapper.pricebookEntryRecord != null){
                if(pwrapper.productRecord.Name != null 
                && pwrapper.productRecord.Name != '' && pwrapper.productRecord.Family != null 
                && pwrapper.productRecord.Family != '' 
                && Constants.SELECT_ONE != pwrapper.productRecord.Family && pwrapper.productRecord.Initial_Inventory__c != null
                && pwrapper.pricebookEntryRecord.UnitPrice != null){
                    System.debug('Saved!');
                    products.add(pwrapper.productRecord);
                    PricebookEntry pbe = pwrapper.pricebookEntryRecord;
                    pbe.IsActive = true;
                    pbe.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    pbEntrys.add(pbe);
                }
            }
        }
        if(products != null && products.size() > 0){
            insert products;
            System.debug('Entered in try' + products);
            for(Integer i=0; i<pbEntrys.size(); i++){
                pbEntrys[i].Product2Id = products[i].Id;
            }
            if(pbEntrys != null && pbEntrys.size() > 0){
                insert pbEntrys;
            }
            //Clear the list and display an informational message if successful
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, products.size() + 'Inserted'));
        }else{
            Database.rollback(sp);
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        productsToInsert.clear();//Do not remove
        AddRows();//Do not remove  
        return null;
    }

    public class ProductWrapper{
        public Product2 productRecord {get; set;}
        public PricebookEntry pricebookEntryRecord {get; set;}

        public ProductWrapper(){
            productRecord = new Product2(Initial_Inventory__c=0);
            pricebookEntryRecord = new PricebookEntry(UnitPrice=0.0);
        }
    }
}