import { BadRequestException, ValidationPipe } from '@nestjs/common';
import { SettingsSectionParamDto } from '../../src/settings/dto/settings-section-param.dto';

describe('SettingsSectionParamDto', () => {
  const pipe = new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
    transformOptions: {
      enableImplicitConversion: true,
    },
  });

  it('accepts supported section keys', async () => {
    const result = await pipe.transform(
      { section: 'company' },
      { type: 'param', metatype: SettingsSectionParamDto },
    );

    expect(result).toEqual({ section: 'company' });
  });

  it('rejects arbitrary section strings with 400', async () => {
    await expect(
      pipe.transform(
        { section: 'arbitrary-section' },
        { type: 'param', metatype: SettingsSectionParamDto },
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
