package edu.virginia.lib.v4.indexing;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class LegacyIndexer {
    
    public static void main(String [] args) throws Exception {
        LegacyIndexer i = new LegacyIndexer();
        i.transformDir(new File("indexed_solr_docs_prod/chadwyck_aap"));
        i.transformDir(new File("indexed_solr_docs_prod/chadwyck_ap"));
        i.transformDir(new File("indexed_solr_docs_prod/chadwyck_ep"));
        i.transformDir(new File("indexed_solr_docs_prod/chadwyck_evd"));
    }

    private File outputDir;
    private Transformer v3tov4;
    
    public LegacyIndexer() throws TransformerConfigurationException {
        outputDir = new File("index");
        outputDir.mkdirs();
        SAXTransformerFactory f = (SAXTransformerFactory) TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
        v3tov4 = f.newTemplates(new StreamSource(getClass().getClassLoader().getResourceAsStream("v3tov4.xsl"))).newTransformer();
    }
    
    public void transformDir(final File dir) throws UnsupportedEncodingException, IOException {
        System.out.print("Transforming documents from " + dir.getAbsolutePath()+ "...");
        final File outputFile = new File(this.outputDir, dir.getName() + "-v4-solr.xml");
        final OutputStream solrOut = new FileOutputStream(outputFile);
        int count = 0;
        try {
            solrOut.write("<add>\n".getBytes("UTF-8"));
            for (File f : dir.listFiles()) {
                if (f.getName().endsWith(".xml")) {
                    transformFile(f, solrOut);
                    count ++;
                }
            }
            solrOut.write("</add>".getBytes("UTF-8"));
        } finally {
            solrOut.flush();
            solrOut.close();
        }
        System.out.println(count + " indexed to " + outputFile.getAbsolutePath());
    }
    
    public void transformFile(final File v3SolrAddDoc, final OutputStream solrOut) throws IOException {
        FileInputStream is = null;
        try {
            is = new FileInputStream(v3SolrAddDoc);
            v3tov4.transform(new StreamSource(is), new StreamResult(solrOut));
        } catch (Throwable t) {
            System.out.println("Error transforming " + v3SolrAddDoc);
            t.printStackTrace();
        } finally {
            if (is != null) {
                is.close();
            }
        }
    }
    
}
