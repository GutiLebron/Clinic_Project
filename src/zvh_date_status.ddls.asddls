@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help para date_status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_DATE_STATUS 
    as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T
    (p_domain_name: 'ZD_CLINIC_DATE_STATUS') as text
{
    @UI.lineItem: [{  position : 10  }]
    key text.value_position as ValuePosition,
    @UI.lineItem: [{  position : 20  }]
    key text.value_low as ValueLow,
    
    @UI.hidden: true
    key text.domain_name as DomainName,
    
    @Semantics.text: true
    @UI.lineItem: [{  position : 30  }]
    text.text           as Description
}

    where
    
        text.language = $session.system_language
