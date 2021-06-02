import { LightningElement,wire,api } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getAllOrderItems from '@salesforce/apex/cmpHelperClass.getAllOrderItems';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Quantity', fieldName: 'quantity'},
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency'},
    { label: 'Total Price ', fieldName: 'totalPrice', type: 'currency'}
];

export default class Cmp2DisplayProducts extends LightningElement { 
    data = [];
    columns = columns;
    record = {};
    @api recordId;
    
    connectedCallback() {

    }

    refreshData(event){
        console.log(event);
        if (event.detail) {
            return refreshApex(this.recordId);
        }
    }
    
    @wire(getAllOrderItems, {
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
                elt.Name = element.Product2.Name;
                elt.unitPrice = element.UnitPrice;
                elt.quantity = element.Quantity;
                elt.totalPrice = element.TotalPrice;
                d.push(elt);
            });
            this.data = d;
        }
    }
}
