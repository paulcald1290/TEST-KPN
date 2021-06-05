import { LightningElement,wire,api } from 'lwc';
import { getRecordNotifyChange} from 'lightning/uiRecordApi';
import getProductsByOrderId from '@salesforce/apex/cmpPriceBookClass.getProductsByOrderId';
import checkExistenceProduct from '@salesforce/apex/cmpOrderItemClass.checkExistenceProduct';
import updateOrderitem from '@salesforce/apex/cmpOrderItemClass.updateOrderitem';
import insertOrderItem from '@salesforce/apex/cmpOrderItemClass.insertOrderItem';
import { MessageContext, publish } from 'lightning/messageService';
import updateMessageChannel from '@salesforce/messageChannel/UpdatedOrderItems__c';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'List Price', fieldName: 'unitPrice', type: 'currency',cellAttributes: { alignment: 'left' }},
    {type: "button", label: 'Actions', fixedWidth:145, typeAttributes: {  
        label: 'Add Product',  
        name: 'add_product',   
        disabled: false,  
        value: 'addProd'  
    }},   
];

export default class Cmp1DisplayProducts extends LightningElement { 
    data = [];
    columns = columns;
    record = {};
    @api recordId;

    @wire(MessageContext)
    messageContext;
    recordId;
    
    connectedCallback() {
    }

    handleRowAction(event) {
        const recId =  event.detail.row.Id; 
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {           
            case 'add_product':
                this.addProduct(row);
                break;
            default:
        }     
    }
    
    @wire(getProductsByOrderId, {
        orderId: '$recordId'
    })
    wiredRecord({ error, data }) {
        if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.data = undefined;
        } else if (data) {
            let d = [];
            data.forEach(element => {
                let elt = {};
                elt.Id = element.Id;
                elt.Name = element.Name;
                elt.unitPrice = element.UnitPrice;
                elt.product2Id = element.Product2Id;
                d.push(elt);
            });
            this.data = d;
        }
    }

    addProduct(product){
        checkExistenceProduct({orderId:this.recordId ,priceBookId: product.Id })
        .then((res) => {
            if (res) {
                this.updateItem(this.recordId,product);
            }
            else{
                this.insertItem(this.recordId,product);
            }
            
        })
        .catch((err) => {
            console.log('Ha ocurrido un error en getData ', err);
        });
    }

    updateItem(recId,product){   
        updateOrderitem({orderId:recId,product2Id: product.product2Id })
        .then((res) => {
            this.publishLMS();
            this.refreshRecord();
        })
        .catch((err) => {
            console.log('Error while updating an Item.', err);
        });
    }

    insertItem(recId,product){   
        insertOrderItem({orderId:recId, 
            unitprice: product.unitPrice, 
            pricebookEntryId: product.Id, 
            product2Id: product.product2Id })
        .then((res) => {
            this.publishLMS();
            this.refreshRecord();
            
        })
        .catch((err) => {
            console.log('Error while inserting a new Item.', err);
        });
    }

    refreshRecord(){
        getRecordNotifyChange([{recordId: this.recordId}]);       
    }

    publishLMS() {
        let flag = true;
        const message = {
            refreshCMP2: flag
        };
        publish(this.messageContext, updateMessageChannel, message);
    }
}
