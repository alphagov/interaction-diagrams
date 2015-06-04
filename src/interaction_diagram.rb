
class InteractionDiagram
  REQUEST_ARROW = '->'
  RESPONSE_ARROW = '-->'
  SOURCE_ON_RIGHT_NOTE_ORIENTATION = 'left'
  SOURCE_ON_LEFT_NOTE_ORIENTATION = 'right'
  BREAK_LINES_PATTERN = /[^\n].{0,100}/

  def initialize(participant_order)
    @participant_order = participant_order
    @participants = []
    @lines = []
  end

  def write_message(source_name, destination_name, message, isResponse)
    add_participants(source_name, destination_name)
    @lines << "#{source_name}#{isResponse ? RESPONSE_ARROW : REQUEST_ARROW}#{destination_name}: #{break_into_lines(message.gsub(/[\r\n]/,''))}"
  end

  def write_note(source_name, destination_name, note)
    add_participants(source_name, destination_name)
    @lines << "note #{participants_displayed_from_left_to_right(source_name, destination_name) ? SOURCE_ON_LEFT_NOTE_ORIENTATION : SOURCE_ON_RIGHT_NOTE_ORIENTATION} of #{source_name}: #{break_into_lines(note.gsub(/[\r\n]/,'').gsub('#','__HASH__'))}"
  end

  def to_s
    @participants.map { |p| "participant " + p}.join("\n") + "\n" +
     @lines.join("\n")
  end

  private

  def add_participants(source_name, destination_name)
    @participants << source_name if !@participants.include?(source_name)
    @participants << destination_name if !@participants.include?(source_name)
    @participants.sort_by! {|p| @participant_order.find_index(p) || participant_order.size + p.hash} # Fall back on the hash as an arbitrary stable order.
  end

  def participants_displayed_from_left_to_right(first_participant, second_participant)
    @participant_order.find_index(first_participant) < @participant_order.find_index(second_participant)
  end

  def break_into_lines(value)
    value.gsub(/\\n/,"\n").scan(BREAK_LINES_PATTERN).join("\n").gsub(/\n/,'\n')
  end
end