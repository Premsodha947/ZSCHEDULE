@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for Sheduling Agreement Update'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSHEDULING_AGREEMENT_UPDATE
  as select from    I_SchedglineApi01       as A
    left outer join ZSHEDULING_AGREEMENT_F4 as B on(
      B.SchedulingAgreement = A.SchedulingAgreement
    )
{   
  key  A.SchedulingAgreement,
  key  A.SchedulingAgreementItem,
  key  A.ScheduleLine,
       B.Plant,
       A.SchedLineStscDeliveryDate,
       A.OrderQuantityUnit,
       @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
       A.RoughGoodsReceiptQty
}
where
  A.ScheduleLineOrderQuantity <> A.RoughGoodsReceiptQty
