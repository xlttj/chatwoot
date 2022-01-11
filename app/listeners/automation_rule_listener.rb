class AutomationRuleListener < BaseListener
  def conversation_status_changed(event_obj)
    conversation = event_obj.data[:conversation]
    return unless rule_present?('conversation_status_changed', conversation)

    @rules.each do |rule|
      conditions_match = ::AutomationRules::ConditionsFilterService.new(rule, conversation).perform
      AutomationRules::ActionService.new(rule, conversation).perform if conditions_match.present?
    end
  end

  def conversation_created(event_obj)
    conversation = event_obj.data[:conversation]
    return unless rule_present?('conversation_created', conversation)

    @rules.each do |rule|
      conditions_match = ::AutomationRule::ConditionsFilterService.new(rule, conversation).perform
      ::AutomationRules::ActionService.new(rule, conversation).perform if conditions_match.present?
    end
  end

  def message_created(event_obj)
    conversation = event_obj.data[:conversation]
    message = event_obj.data[:message]
    return unless rule_present?('message_created', conversation)

    @rules.each do |rule|
      conditions_match = ::AutomationRules::ConditionsFilterService.new(rule, conversation).message_conditions(message)
      ::AutomationRules::ActionService.new(rule, conversation).perform if conditions_match.present?
    end
  end

  def rule_present?(event_name, conversation)
    return if conversation.blank?

    @rules = AutomationRule.where(
      event_name: event_name,
      account_id: conversation.account_id
    )
    @rules.any?
  end
end
