@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for Sheduling Agreement F4'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSHEDULING_AGREEMENT_F4
  as select from I_SchedgAgrmtItmApi01 as A
{
  key A.SchedulingAgreement,
      A.Plant
}
group by
  A.SchedulingAgreement,
  A.Plant
