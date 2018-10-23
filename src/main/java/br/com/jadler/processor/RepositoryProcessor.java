package br.com.jadler.processor;

import com.google.auto.service.AutoService;
import freemarker.core.ParseException;
import freemarker.template.Configuration;
import freemarker.template.MalformedTemplateNameException;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.TypeElement;
import javax.tools.JavaFileObject;

/**
 * Cria uma classe Repository para cada classe com a anotação
 * {@literal @}RepositoryProperty no mesmo pacote
 *
 * @since 1.0
 * @version 1.1
 * @author <a href="mailto:jaguar.adler@gmail.com">Jaguaraquem A. Reinaldo</a>
 */
@SupportedAnnotationTypes("br.com.jadler.annotation.RepositoryProperty")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
@AutoService(Processor.class)
public class RepositoryProcessor extends AbstractProcessor {

    private Configuration cfg = null;
    private Template t = null;

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment env) {

        Map<String, Object> map = new HashMap();
        annotations.forEach(a -> {
            env.getElementsAnnotatedWith(a).stream().forEach(e -> {

                String[] input = e.toString().split("\\.");

                if (input.length > 1) {
                    String[] output = Arrays.copyOfRange(input, 0, input.length - 1);
                    output[output.length - 1] = "repository";
                    map.put("package", String.join(".", output));
                }

                map.put("import", e.toString());
                map.put("inClass", input[input.length - 1]);
                map.put("outClass", input[input.length - 1] + "Repository");

                try {
                    write(map);
                } catch (IOException | TemplateException ex) {
                    System.out.println(ex.getMessage());
                }
            });
        });

        return true;
    }

    private void write(Map<String, Object> map) throws MalformedTemplateNameException, ParseException, IOException, TemplateException {
        cfg = new Configuration(Configuration.getVersion());
        cfg.setClassForTemplateLoading(this.getClass(), "/");

        t = cfg.getTemplate("/repository.ftl");

        String output = String.format("%s.%s", map.get("package"), map.get("outClass"));
        JavaFileObject file = processingEnv.getFiler().createSourceFile(output);

        try (Writer writer = new PrintWriter(file.openWriter())) {
            t.process(map, writer);
            writer.flush();
        }
    }
}
