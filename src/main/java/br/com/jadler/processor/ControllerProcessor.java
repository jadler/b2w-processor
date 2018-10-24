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
import java.util.stream.Collectors;
import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import static javax.lang.model.element.ElementKind.CLASS;
import static javax.lang.model.element.ElementKind.FIELD;
import javax.lang.model.element.TypeElement;
import javax.tools.JavaFileObject;

/**
 * Cria uma classe Controller para cada classe com a anotação
 * {@literal @}ControllerProperty no mesmo pacote
 *
 * @since 1.1
 * @version 1.2
 * @author <a href="mailto:jaguar.adler@gmail.com">Jaguaraquem A. Reinaldo</a>
 */
@SupportedAnnotationTypes({
    "br.com.jadler.annotation.ControllerProperty",
    "br.com.jadler.annotation.MappedProperty"
})
@SupportedSourceVersion(SourceVersion.RELEASE_8)
@AutoService(Processor.class)
public class ControllerProcessor extends AbstractProcessor {

    private Configuration cfg = null;
    private Template t = null;

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment env) {

        Map<String, Map<String, Object>> mmap = new HashMap();

        annotations.stream().forEach(a -> {

            env.getElementsAnnotatedWith(a).stream()
                    .filter(e -> e.getKind().equals(CLASS))
                    .forEach(e -> {

                        Map m = mmap.getOrDefault(e.toString(), new HashMap());
                        String[] input = e.toString().split("\\.");

                        if (input.length > 1) {
                            String[] output = Arrays.copyOfRange(input, 0, input.length - 1);
                            output[output.length - 1] = "controller";
                            m.put("package", String.join(".", output));
                        }

                        m.put("import", e.toString());
                        m.put("inClass", input[input.length - 1]);
                        m.put("outClass", input[input.length - 1] + "Controller");
                    });

            env.getElementsAnnotatedWith(a).stream()
                    .filter(e -> e.getKind().equals(FIELD))
                    .collect(Collectors.groupingBy(p -> p.getEnclosingElement().toString()))
                    .entrySet().forEach(m -> {
                        Map map = mmap.getOrDefault(m.getKey(), new HashMap());
                        map.put("elements", m.getValue());
                        mmap.put(m.getKey(), map);
                    });
        });

        mmap.entrySet().forEach(m -> {
            try {
                write(m.getValue());
            } catch (IOException | TemplateException ex) {
                System.err.println(ex.getMessage());
            }
        });

        return true;
    }

    private void write(Map<String, Object> map) throws MalformedTemplateNameException, ParseException, IOException, TemplateException {
        cfg = new Configuration(Configuration.getVersion());
        cfg.setClassForTemplateLoading(this.getClass(), "/");

        t = cfg.getTemplate("/controller.ftl");

        String output = String.format("%s.%s", map.get("package"), map.get("outClass"));
        JavaFileObject file = processingEnv.getFiler().createSourceFile(output);

        try (Writer writer = new PrintWriter(file.openWriter())) {
            t.process(map, writer);
            writer.flush();
        }
    }
}
