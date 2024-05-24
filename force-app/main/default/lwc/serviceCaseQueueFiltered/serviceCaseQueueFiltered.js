import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getUserCases from '@salesforce/apex/ServiceCaseQueueService.getUserCases';
import getStatusPicklistValues from '@salesforce/apex/ServiceCaseQueueService.getStatusPicklistValues';
import updateStatus from '@salesforce/apex/ServiceCaseQueueService.updateStatus';
import getUserCasesNonCacheable from '@salesforce/apex/ServiceCaseQueueService.getUserCasesNonCacheable';
import {refreshApex} from '@salesforce/apex';

export default class ServiceCaseQueueFiltered extends NavigationMixin(LightningElement) {

    optionsLoaded = false;
    casesLoaded = false;
    isLoaded = false;

    options = [];

    @wire(getStatusPicklistValues) wiredStatusPicklistValues(picklistValues){

        const { error, data } = picklistValues;
        if(data){
            data.forEach(i => {
                this.options.push({label:i,value:i});
            });
            this.optionsLoaded = true;
            if (this.optionsLoaded && this.casesLoaded) {
                this.isLoaded = true;
            }
        } else if (error) {
            console.error('Error fetching status picklist values: ', error);
        }
    };

    cases;

    @wire(getUserCases) wiredUserCases(userCases) {

        const { error, data } = userCases;
        if (data) {
            this.cases = this.addNumberToData(data);
            this.casesLoaded = true;
            if (this.optionsLoaded && this.casesLoaded) {
                this.isLoaded = true;
            }
        } else if (error) {
            console.error('Error fetching customer data: ', error);
        }
    }

    viewRecord(event) {

        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    async changeStatus(event) {

        this.isLoaded = false;
        const newStatus = event.detail.value;
        const caseId = event.target.dataset.id;
        await updateStatus({ newStatus: newStatus, caseId: caseId})
            .then((result) => {
                getUserCasesNonCacheable()
                    .then(data => {
                        this.cases = this.addNumberToData(data);
                        refreshApex(this.cases);
                        this.isLoaded = true;
                    })
                    .catch(error => {
                        console.log(error);
                    })
                this.showCaseUpdatedToast();
            })
            .catch((error) => {
                this.showErrorToast(error);
            });
    }
    
    async updateTable() {
        
        this.isLoaded = false;
        await getUserCasesNonCacheable()
            .then((data) => {
                this.cases = this.addNumberToData(data);
                refreshApex(this.cases);
                this.isLoaded = true;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    addNumberToData(data) {

        let casesWithNumeration = [];
        for (let index = 0; index < data.length; index++) {
            const element = JSON.parse(JSON.stringify(data[index]));
            element.Number = (index + 1).toString();
            casesWithNumeration.push(element);
        }
        return casesWithNumeration;
    }

    showCaseUpdatedToast() {

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: "Case updated",
                variant: "success",
            }),
        );
    }

    showErrorToast(error) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error updating record",
                message: error.body.message,
                variant: "error",
            }),
        );
    }  
}