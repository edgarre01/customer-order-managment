import { LightningElement, wire, track } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";
import { NavigationMixin } from "lightning/navigation";



const pageSize = 3;
const columns = [
    { label: 'Order Name', fieldName: 'Name', type: 'text' },
    { label: 'Customer Name', fieldName: 'Customer__r.Name', type: 'text' },
    { label: 'Customer Email', fieldName: 'Customer__r.Email__c', type: 'email' },
    { label: 'Due Date', fieldName: 'DueDate__c', type: 'date', cellAttributes: { class: { fieldName: 'class' }}},
    { label: 'Shipping Address', fieldName: 'ShippingAddress__c', type: 'text' },
    { label: 'Weather', fieldName: 'WeatherDescription__c', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: [
            { label: 'View', name: 'view' },
            { label: 'Edit', name: 'edit' }
        ], menuAlignment: 'auto' }
    },
];

export default class OrderList extends NavigationMixin(LightningElement) {
    prevPage = [];
    after;
    @track dataTable = []
    recordsUI;
    errorsUI;
    pageNumber = 1;
    columns = columns;
    userCoordinates = {}

    connectedCallback() {
        let self = this;
        if ("geolocation" in navigator) {
            navigator.geolocation.watchPosition(function(pos){
                    console.log(pos);
                    self.userCoordinates = pos.coords;
                },function(err) {
                    console.log(err)
                });
        } else {
            /* geolocation IS NOT available */
        }
       
    }

    renderedCallback(){
        let style = document.createElement('style');        
        style.innerText = '.color-red{background-color: red;}';
        this.template.querySelector('.new').appendChild(style);
    }

    

    @wire(graphql, {
        query: gql`
        query paginatedRecords($after: String, $pageSize: Int!) {
            uiapi {
                query {
                    Order__c(first: $pageSize, after: $after, orderBy: { Name: { order: ASC } }) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                                DueDate__c{
                                    value
                                }
                                ShippingAddress__c{
                                    value
                                }
                                WeatherDescription__c{
                                    value
                                }
                                Customer__r {
                                    Id
                                    Name {
                                        value
                                    }
                                    Email__c {
                                        value
                                    }
                                }
                            }
                        }
                        pageInfo {
                            endCursor
                            startCursor
                            hasNextPage
                            hasPreviousPage
                        }
                    }
                }
            }
        }`,
        variables: "$variables",
    })
    waredGrahpQLResults({data, errors}) {
        if (errors) {
            console.error(errors);
            this.errorsUI = errors;
        } else if (data) {
            console.log('data:',data);
            this.recordsUI = data;
            this.dataTable = [];
            if(this.recordsUI?.uiapi.query.Order__c.edges){
                for(let i = 0; i < this.recordsUI?.uiapi.query.Order__c.edges.length; i++){
                    let recordQL = this.recordsUI?.uiapi.query.Order__c.edges[i].node;
                    let record = {}
                    console.log('recordQL:',recordQL);
                    record = this.transformData(record, recordQL);
                    console.log('record', record)
                    if(record['DueDate__c'] && new Date(record['DueDate__c']) < new Date()){
                        record['class'] = 'color-red';
                    }
                    this.dataTable.push(record);
                }
            }
    
            console.log('this.dataTable:',JSON.stringify(this.dataTable));
            
        }
    }

    get variables() {
        return {
            after: this.after || null,
            pageSize,
        };
    }

    get isFirstPage() {
        return !this.recordsUI?.uiapi.query.Order__c.pageInfo.hasPreviousPage;
    }

    get isLastPage() {
        return !this.recordsUI?.uiapi.query.Order__c.pageInfo.hasNextPage;
    }

    handlePrev() {
        if (this.prevPage) {
            this.after = this.prevPage.pop();
            this.pageNumber--;
        }
    }

    handleNext() {
        this.prevPage.push(this.after);
        if (this.recordsUI?.uiapi.query.Order__c.pageInfo.hasNextPage) {
            this.after = this.recordsUI?.uiapi.query.Order__c.pageInfo.endCursor;
            this.pageNumber++;
        }
    }

    handleReset() {
        this.after = null;
        this.pageNumber = 1;
    }

    handleRowAction(event){
        const action = event.detail.action;
            const row = event.detail.row;
            switch (action.name) {
                case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id, // pass the record id here.
                            actionName: 'view',
                        },
                    });
                    break;
                case 'edit':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id, // pass the record id here.
                            actionName: 'edit',
                        },
                    });
                    break;
            }
    }

    handleNew(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName : 'Order__c',
                actionName: 'new',
            },
            // state: {
            //     defaultFieldValues: {}, // assing default values
            // },
        });
    }

    transformData(record, recordQL){
        Object.keys(recordQL).forEach(key => {  
            if (recordQL[key] && typeof recordQL[key] == 'object' && 'displayValue' in recordQL[key]){
                record[key] = recordQL[key].displayValue;
            } else if (recordQL[key] && typeof recordQL[key] == 'object' && 'value' in recordQL[key]){
                record[key] = recordQL[key].value;
            } else if(typeof recordQL[key] == 'object') {
                let parentRecords = this.transformData({}, recordQL[key]);
                Object.keys(parentRecords).forEach(keyParent => {  
                    record[key+'.'+keyParent] = parentRecords[keyParent];
                })
            }else {
                record[key] = recordQL[key];
            }
        });
        return record;
    }
}