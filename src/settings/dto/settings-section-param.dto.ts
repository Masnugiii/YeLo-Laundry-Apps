import { IsIn } from 'class-validator';
import { SETTINGS_SECTIONS, SettingsSection } from '../settings.types';

export class SettingsSectionParamDto {
  @IsIn([...SETTINGS_SECTIONS])
  section!: SettingsSection;
}
