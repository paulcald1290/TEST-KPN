import { LightningElement,track,wire,api } from 'lwc';
import { MessageContext, subscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UMC from '@salesforce/messageChannel/UpdatedOrderItems__c';
import getAllOrderItems from '@salesforce/apex/cmpOrderItemClass.getAllOrderItems';
import sendRequestOrder from '@salesforce/apex/JSONHelperClass.sendOrderByPOST';
import updateOrderStatus from '@salesforce/apex/cmpOrderClass.UpdateOrderStatus';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Quantity', fieldName: 'quantity'},
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency',cellAttributes: { alignment: 'left' }},
    { label: 'Total Price ', fieldName: 'totalPrice', type: 'currency',cellAttributes: { alignment: 'left' }}
];

export default class Cmp2DisplayProducts extends LightningElement { 
    data = [];
    columns = columns;
    record = {};
    @api recordId;
    @wire(MessageContext) messageContext;
    totalProducts = 0;
    subscription = null;
    @track isButtonDisabled = false;
    
    connectedCallback() {
        this.loadData();
        this.subscribeMC();
    }

    loadData(){
        getAllOrderItems({orderId:this.recordId})
        .then((res) => {
            let d = [];
            this.totalProducts = 0;
            res.forEach(element => {
                let elt = {};
                elt.Name = element.Product2.Name;
                elt.unitPrice = element.UnitPrice;
                elt.quantity = element.Quantity;
                this.totalProducts += element.Quantity;
                elt.totalPrice = element.TotalPrice;
                elt.productCode = element.Product2.ProductCode;
                d.push(elt);
            });
            this.data = d;
        })
        .catch((err) => {
            console.log('An error happend while loading data. ', err);
        });
    }

    subscribeMC() {
        try {
            if (this.subscription) {
                return;
            }
            this.subscription = subscribe(
                this.messageContext,
                UMC,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        } catch (error) {
            console.log('Error while subscribing. ', error);
        }
    }
    
    handleMessage(message) {
        try {
            console.log(JSON.stringify(message));
            if (message.refreshCMP2) {
                this.loadData();
                this.handleToastEvent('Success', 'Order Item added successfully.', 'success');
            }
        } catch (error) {
            console.log('Error while refreshing. ', error);
        }
    }

    handleToastEvent(title, message, variant) {
        const toast = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(toast);
    }

    sendRequest(event){
        sendRequestOrder({orderId:this.recordId, products: JSON.stringify(this.data)})
        .then((res) => {
            
            if (res == 200) {
                this.updateOrder(this.recordId);
                
            }else{

            }
        })
        .catch((err) => {
            console.log('An error happened while sending order For Confirmation.', err);
        });
        this.isButtonDisabled = true;
    }
    
    updateOrder(ordId){
        updateOrderStatus({orderId:ordId})
                .then((res) => {
                    if (res == true) {
                        this.handleToastEvent('Success', 'Order completed successfully.', 'success');
                    }
                })
                .catch((err) => {
                    console.log('An error happened while closing Order', err);
                });
    }
}
